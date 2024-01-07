// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IOrderBook {
    enum OrderType { 
        Buy, 
        Sell, 
        BuyLimit, 
        SellLimit,
        BuyStopLimit,
        SellStopLimit,
        BuyIOC,             // Buy immediately or cancel
        SellIOC,            // Sell immediately or cancel
        BuyFOK,             // Buy fill ot kill
        SellFOK,            // Sell fill or kill
        BuyAON,             // Buy all or none
        SellAON,            // Sell all or none
        BuyGTD,             // Buy good til day
        SellGTD             // Sell good til day
    }

    struct Order {
        address trader;
        OrderType orderType;
        uint256 price;
        uint256 quantity;
        uint256 limitPrice; // Added for limit orders
        uint256 stopPrice;  // Added for stop-limit orders
        bool immediateOrCancel; // Added for Immediate or Cancel orders
        bool fillOrKill; // Added for Fill or Kill orders
        bool allOrNone; // Added for All or None orders
        uint256 expirationDate; // Added for Good 'Til Date orders
    }

    // Event to log order placement
    event OrderPlaced(address token,address indexed trader, OrderType orderType, uint256 price, uint256 quantity, uint256 limitPrice, uint256 stopPrice);
    event OrderExecuted(address indexed token,address indexed buyer, address indexed seller, uint256 price, uint256 quantity);
    event OrderExpired(uint256 index, OrderType orderType, address trader);

    function setContract(address catAddress,address exchangeFeeAddress,address paymentWalletAddress,address quoteHistoricalAddress) external;
    function setCATContract(address catAddress) external;
    function setExchangeFeeContract(address exchangeFeeAddress) external;
    function setPaymentWalletContract(address paymentWalletAddress) external;
    function setQuoteHistoricalContract(address quoteHistoricalAddress) external;
    function setOfferingContractAddress(string calldata symbol,address offeringContractAddress) external;

    function placeMarketOrder(string calldata _symbol, OrderType _orderType, uint256 _quantity, uint256 _slippagePercentage, uint256 _expirationDate) external returns(uint256);
    function getBestPrice(string calldata _symbol, OrderType _orderType) external returns (uint256);
    function quote(string calldata symbol) external returns (uint256,uint256,uint256,uint256,uint256);
}