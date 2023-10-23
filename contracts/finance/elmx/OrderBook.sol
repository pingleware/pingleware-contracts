// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * PERFORM ORDER MATCHING OFF CHAIN and upon completion of the order, update the exchangeContract with a digital record of shares
 * transferred between buyer and seller.
 *
 * When an investor wishes to BUY a security, they first select the security and quantity which calculates the price + fee,
 * then money transmitter (STRIPE) is prompted to take payment and payment funds transferred to issuer via STRIPE,
 * on successful webhook payment, the smart contract instance is invoke passing the number of shares the investor just bought
 */

import "../../libs/SafeMath.sol";
import "../../interfaces/IOffering.sol";
import "../../interfaces/IConsolidatedAuditTrail.sol";
import "../../interfaces/IExemptLiquidityMarketExchange.sol";
import "../../interfaces/IExchangeFee.sol";
import "../../interfaces/IOrderBook.sol";

contract OrderBook is IOrderBook {
    IConsolidatedAuditTrail public catContract;
    IExemptLiquidityMarketExchange public exchangeContract;
    IExchangeFee public exchangeFeeContract;

    mapping(string => IOffering) offering;

    mapping(string => Order[]) public buyOrders;
    mapping(string => Order[]) public sellOrders;

    mapping(string => uint256) public nextOrderId;

    mapping(string => uint256) public highestBid;
    mapping(string => uint256) public lowestAsk;


    address public feeRecipient;
    uint256 public FeePercentage = 1; // Fee percentage

    uint256 threshold = 10; // Adjust this threshold based on your requirements
    uint256 priceThreshold = 5; // Adjust this threshold based on your requirements

    event FeeRecipientUpdated(address indexed newRecipient);
    event FeePercentageUpdated(uint256 newPercentage);


    // Event emitted when a new buy order is placed
    event BuyOrderPlaced(string indexed currencyPair,address indexed trader,uint256 amount,uint256 price);

    // Event emitted when a new sell order is placed
    event SellOrderPlaced(string indexed currencyPair,address indexed trader,uint256 amount,uint256 price);

    // Event emitted when a trade is executed
    event TradeExecuted(string indexed currencyPair,address indexed buyer,address indexed seller,uint256 amount,uint256 price);

    event ValueTransferred(address sender, uint256 amount);

    event ManipulativeBehaviorDetected(address sender,string symbol,uint256 orderId);
    event MarketAbuseDetetcted(address sender,string symbol,uint256 orderId);

    constructor(address exchangeAddress,address catContractAddress,address exchangeFeeAddress) {
        exchangeContract = IExemptLiquidityMarketExchange(exchangeAddress);
        catContract = IConsolidatedAuditTrail(catContractAddress);
        exchangeFeeContract = IExchangeFee(exchangeFeeAddress);
    }


    function setThreshold(uint256 value) external  {
        threshold = value;
    }

    function setPriceThreshold(uint256 value) external  {
        priceThreshold = value;
    }

    function setFeeRecipient(address wallet) external  {
        feeRecipient = address(wallet);
        emit FeeRecipientUpdated(wallet);       
    }

    function setFee(uint256 fee) external  {
        require(fee <= 100, "Fee percentage must be 100 or less");
        FeePercentage = fee; // 1=1% deposit fee
        emit FeePercentageUpdated(fee);
    }

    function setOfferingContractAddress(string calldata symbol,address offeringContractAddress) external  {
        offering[symbol] = IOffering(offeringContractAddress);
    }

    function getOrders(string calldata symbol) external view returns(Order[] memory,Order[] memory) {
        require(address(offering[symbol]) != address(0x0),"offering is not set");
        return(buyOrders[symbol],sellOrders[symbol]);
    }

    // INTERNAL FUNCTIONS

    // Function to update the highest bid and lowest ask prices
    function updateQuoting(string calldata symbol) internal {    
        uint256 i = 0;
        uint256 j = 0;

        highestBid[symbol] = buyOrders[symbol][0].price;
        for (i=1; i<buyOrders[symbol].length; i++) {
            if (buyOrders[symbol][i].price > highestBid[symbol]) {
                highestBid[symbol] = buyOrders[symbol][i].price;
            }
        }

        lowestAsk[symbol] = sellOrders[symbol][0].price;
        for(j=1;j<sellOrders[symbol].length;j++) {
            if (sellOrders[symbol][j].price < lowestAsk[symbol]) {
                lowestAsk[symbol] = sellOrders[symbol][j].price;
            }
        }
    }
    // Function to match buy and sell orders
    function matchOrders(string calldata symbol) internal {
        if (buyOrders[symbol].length == 0 || sellOrders[symbol].length == 0) {
            return;
        }

        uint256 i = 0;
        uint256 j = 0;

        while (i < buyOrders[symbol].length && j < sellOrders[symbol].length) {
            Order memory buyOrder = buyOrders[symbol][i];
            Order memory sellOrder = sellOrders[symbol][j];

            if (buyOrder.price >= sellOrder.price) {
                uint256 tradeAmount = (buyOrder.quantity <= sellOrder.quantity)
                    ? buyOrder.quantity
                    : sellOrder.quantity;
                uint256 tradePrice = sellOrder.price;

                emit TradeExecuted(symbol,buyOrder.wallet,sellOrder.wallet,tradeAmount,tradePrice);

                // transfer the tokens on the contract
                offering[symbol].transferFrom(sellOrder.wallet,buyOrder.wallet,tradeAmount);


                // Update order amounts and remove filled orders
                if (buyOrder.quantity <= sellOrder.quantity) {
                    sellOrders[symbol][j].quantity -= buyOrder.quantity;
                    delete buyOrders[symbol][i];
                    i++;
                } else {
                    buyOrders[symbol][i].quantity -= sellOrder.quantity;
                    delete sellOrders[symbol][j];
                    j++;
                }
                // Calculate the total fee amount
                int256 Fee = int256((tradePrice * FeePercentage) / 100);
                // Transfer the fee amount to the fee recipient
                if (Fee > 0) {
                    exchangeFeeContract.addFee(buyOrder.wallet, Fee);
                }

                // save CAT
                string memory eventData = string(abi.encodePacked("SELLER: ", sellOrder.wallet, ", BUYER: ", buyOrder.wallet, ", AMOUNT: ", catContract.uintToString(tradeAmount),", PRICE: ", catContract.uintToString(tradePrice)));
                catContract.addAuditEntry(symbol,catContract.timestampToString(),"Match Orders",eventData);
            } else {
                break;
            }
        }
    }
    // Function to get quote
    function quote(string calldata symbol)
        external
        view
        returns (uint256, uint256)
    {
        return (highestBid[symbol],lowestAsk[symbol]);
    }
    // Function to place a buy order
    function buy(
        address wallet,
        string calldata symbol,
        uint256 quantity,
        uint256 price,
        uint256 amount
    ) external  {
        require(address(offering[symbol]) != address(0x0),"offering is not set");
        require(exchangeContract.isWhitelisted(wallet),"not authorized as a whitelisted user");
        require(offering[symbol].getTradingStatus(),"trading has been suspended");
        require(quantity > 0 && price > 0, "Invalid amount and/or price");
        require(amount > SafeMath.safeMul(quantity, price),"insufficient funds to place buy order");
        require(offering[symbol].getOutstandingShares() == offering[symbol].getTotalSupply(),"trading disabled until funding round has been completed");

        // Storing the buy order details
        Order memory order = Order(nextOrderId[symbol], wallet, quantity, price, amount);
        buyOrders[symbol][nextOrderId[symbol]] = order;


        if (detectManipulativeBehaviorDetected(symbol, nextOrderId[symbol])) {
            emit ManipulativeBehaviorDetected(wallet,symbol,nextOrderId[symbol]);
            offering[symbol].changeTradingStatus(false,"Manipulative Behavior Detected");
        } else {
            if (detectMarketAbuse(symbol)) {
                emit MarketAbuseDetetcted(wallet, symbol, nextOrderId[symbol]);
                offering[symbol].changeTradingStatus(false,"Market Abuse Detected");
            } else {
                nextOrderId[symbol]++;

                updateQuoting(symbol);
                matchOrders(symbol);
                emit BuyOrderPlaced(symbol, wallet, quantity, price);

                string memory eventData = string(abi.encodePacked("BUYER: ", wallet, ", AMOUNT: ", catContract.uintToString(quantity),", PRICE: ", catContract.uintToString(price), ", ORDERID: ", catContract.uintToString(nextOrderId[symbol])));
                catContract.addAuditEntry(symbol,catContract.timestampToString(),"Buy Order",eventData);
            }
        }
    }
    // Function to cancel and transfer contract balance to the caller, and remove the buy order
    function cancelBuy(address wallet, string calldata symbol,uint256 orderId) external  {
        require(address(offering[symbol]) != address(0x0),"offering is not set");
        require(exchangeContract.isWhitelisted(wallet),"not authorized as a whitelisted user");
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "Contract has no balance.");

        Order storage order = buyOrders[symbol][orderId];
        require(order.wallet == wallet, "Not the owner of this order.");

        uint256 refund = order.paid;

        delete buyOrders[symbol][orderId];

        //payable(msg.sender).transfer(refund);
        emit ValueTransferred(wallet, refund);

        string memory eventData = string(abi.encodePacked("BUYER: ", wallet, ", ORDERID: ", catContract.uintToString(orderId),", REFUND: ", catContract.uintToString(refund)));
        catContract.addAuditEntry(symbol,catContract.timestampToString(),"Cancel Buy Order",eventData);
    }
    // Function to place a sell order
    function sell(
        address wallet,
        string calldata symbol,
        uint256 quantity,
        uint256 price
    ) external  {
        require(address(offering[symbol]) != address(0x0),"offering is not set");
        require(exchangeContract.isWhitelisted(wallet),"not authorized as a whitelisted user");
        require(offering[symbol].getTradingStatus(),"trading has been suspended");
        require(quantity > 0, "Invalid amount");
        require(price > 0, "Invalid price");
        require(quantity > 0 && price > 0, "Invalid amount and/or price");
        require(offering[symbol].getOutstandingShares() == offering[symbol].getTotalSupply(),"trading disabled until initial offering has been completed");
        require(offering[symbol].getBalanceFrom(wallet) >= quantity,"insufficient balance in sellers account");

        Order memory order = Order(nextOrderId[symbol], wallet, quantity, price, 0);
        sellOrders[symbol][nextOrderId[symbol]] = order;

        string memory eventData = string(abi.encodePacked("SELLER: ", wallet, ", AMOUNT: ", catContract.uintToString(quantity),", PRICE: ", catContract.uintToString(price), ", ORDERID: ", catContract.uintToString(nextOrderId[symbol])));
        catContract.addAuditEntry(symbol,catContract.timestampToString(),"Sell Order",eventData);


        if (detectManipulativeBehaviorDetected(symbol, nextOrderId[symbol])) {
            emit ManipulativeBehaviorDetected(wallet,symbol,nextOrderId[symbol]);
            offering[symbol].changeTradingStatus(false,"Manipulative Behavior Detected");
        } else {
            nextOrderId[symbol]++;
            updateQuoting(symbol);
            matchOrders(symbol);
            emit SellOrderPlaced(symbol, wallet, quantity, price);
        }
    }
    // Cancel pending sell order
    function cancelSell(address wallet,string calldata symbol,uint256 orderId) external  {
        require(address(offering[symbol]) != address(0x0),"offering is not set");
        require(exchangeContract.isWhitelisted(wallet),"not authorized as a whitelisted user");
        Order storage order = sellOrders[symbol][orderId];
        require(order.wallet == wallet, "not the owner of this order.");
        delete sellOrders[symbol][orderId];

        string memory eventData = string(abi.encodePacked("SELLER: ", wallet, ", ORDERID: ", catContract.uintToString(orderId)));
        catContract.addAuditEntry(symbol,catContract.timestampToString(),"Cancel Sell Order",eventData);
    }

    function detectMarketAbuse(string memory symbol) public view  returns (bool) {
        // Calculate average bid and ask prices
        uint256 sumBids;
        for (uint256 i = 0; i < buyOrders[symbol].length; i++) {
            sumBids += buyOrders[symbol][i].price;
        }
        uint256 averageBid = sumBids / buyOrders[symbol].length;

        uint256 sumAsks;
        for (uint256 i = 0; i < sellOrders[symbol].length; i++) {
            sumAsks += sellOrders[symbol][i].price;
        }
        uint256 averageAsk = sumAsks / sellOrders[symbol].length;

        // Calculate bid-ask spread
        uint256 spread = averageAsk - averageBid;

        // Check for potential market abuse
        if (spread >= threshold) {
            return true;
        }
        return false;
    }

    function detectManipulativeBehaviorDetected(string memory symbol,uint256 orderId) public view  returns (bool) {
        // Check if the order price deviates significantly from the current market price
        //uint256 priceDeviation = order.price > orderBook.currentPrice ? order.price - orderBook.currentPrice : orderBook.currentPrice - order.price;
        uint256 bidPriceDeviation = buyOrders[symbol][orderId].price > highestBid[symbol] ? buyOrders[symbol][orderId].price - highestBid[symbol] : highestBid[symbol] - buyOrders[symbol][orderId].price;
        uint256 askPriceDeviation = sellOrders[symbol][orderId].price < lowestAsk[symbol] ? lowestAsk[symbol] - sellOrders[symbol][orderId].price : sellOrders[symbol][orderId].price - lowestAsk[symbol];

        // Check for potential manipulative behavior
        if (bidPriceDeviation >= priceThreshold || askPriceDeviation > priceThreshold) {
            return true;
        }
        return false;
    }
}