// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IExemptLiquidityMarketExchange.sol";
import "../../interfaces/IPaymentWallet.sol";
import "../../abstract/AEquityToken.sol";

contract Reg147Equity is AEquityToken {
    /**
     * About Rule 147 Secutrity Restrictions
     * See https://www.sec.gov/info/smallbus/secg/intrastate-offering-exemptions-compliance-guide-041917
     *
     * Securities purchased in an offering pursuant to Rule 147 or Rule 147A can only be resold to persons residing in-state for a period of six months from the date of the sale by the issuer to the purchaser. 
     * Issuers must disclose these limitations on resale to offerees and purchasers and include appropriate legends on the certificate or document evidencing the security. 
     * Although securities purchased in an offering pursuant to Rule 147 or Rule 147A are not considered “restricted securities,” 
     * persons reselling the securities will nonetheless need to register the transaction with the Commission or have an exemption from registration under federal law
     */

    bool public restricted = false; 

    IExemptLiquidityMarketExchange public exchangeContract;

    mapping(address => uint256) public transfer_log;

    address public owner;
    address public issuer;

    event Transfer(address,address,uint256);

    string public homeJurisdiction;
    address public feeRecipient;
    uint256 public FeePercentage = 1;

    uint256 public bid;
    uint256 public ask;

    constructor(address tokenIssuer,string memory debtOrEquity,string memory jurisdiction,string memory tokenName,string memory tokenSymbol,uint256 tokenSupply,uint256 tokenPrice,address redeecashExchangeAddress) {
        owner = msg.sender;
        issuer = tokenIssuer;

        homeJurisdiction = jurisdiction;
        name = tokenName;
        symbol = tokenSymbol;
        totalSupply = tokenSupply;
        price = tokenPrice;
        offeringType = debtOrEquity;


        exchangeContract = IExemptLiquidityMarketExchange(redeecashExchangeAddress);

        MAX_OFFERING_SHARES = tokenSupply;

        exchangeContract.assignToken(address(this), tokenIssuer, tokenName, tokenSymbol, totalSupply, "Reg147");
        exchangeContract.setOfferingContractAddress(symbol,address(this));
    }

    modifier isOwner() {
        require(msg.sender == owner,"NO");
        _;
    }

    function getIssuer() external view returns (address) {
        return issuer;
    }

    function getBalanceFrom(address wallet) external view returns (uint256) {
        return uint256(exchangeContract.getShares(wallet,address(this)));
    }


    function addInvestor(address wallet) external isOwner {
        require(findJurisdiction(exchangeContract.getInvestorJurisdiction(wallet)),"out of jurisdiction");
        exchangeContract.addInvestor(symbol, wallet);
    }

    function setFeeRecipient(address wallet) external isOwner {
        feeRecipient = wallet;
    }


    function transferOnChainPurchase(address from, address to, uint tokens) external isOwner {
        // Calculate the total fee amount
        uint256 Fee = (exchangeContract.usdToWei(SafeMath.safeMul(price,tokens)) * FeePercentage) / 100;

        if (Fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",symbol," token")),int256(Fee),int256(Fee));
        }

        transfer(from,to,tokens);
    }

    /**
     * @dev transfer : Transfer token to another etherum address
     */ 
    function transfer(address from,address to, uint tokens) public isOwner returns (bool success) {
        return transferFrom(from, to, tokens);
    }

    /**
     * @dev transferFrom : Transfer token after approval 
     */ 
    function transferFrom(address from, address to, uint tokens) public isOwner returns (bool success) {
        //require(validate(from, to, tokens),"not valid");

        if (from != issuer) {
            require (block.timestamp >= (transfer_log[from] + SIXMONTHS),"237.147(e)");
            require (keccak256(abi.encodePacked(exchangeContract.getInvestorJurisdiction(from))) ==  keccak256(abi.encodePacked(exchangeContract.getInvestorJurisdiction(to))),"cannot be sold across jursidcitons");
        }
        exchangeContract.transferShares(from, to, address(this), int256(tokens));
        transfer_log[to] = block.timestamp;

        if (exchangeContract.isTransferAgent(from)) {
            OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
        }
        emit Transfer(from, to, tokens);

        // save CAT
        string memory eventData = string(abi.encodePacked("FROM: ", from, ", TO: ", to, ", AMOUNT: ", exchangeContract.uintToString(tokens)));
        exchangeContract.addAuditEntry(symbol,exchangeContract.timestampToString(),"Transfer Token",eventData);

        return true;
    }

    /**
     * Funding round:
     * 1. Investor specifies number of shares to buy
     * 2. Jurisdiction is vallidated and match with the Issuer
     * 3. 
     */
    function buy(address wallet,uint256 tokens,uint256 Fee) external isOwner {
        require(tokens <= totalSupply,"too many tokens");
        // payments transferred off-chain
        if (Fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",symbol," token")),int256(Fee),int256(Fee));
        }
        // adjust the total supply for tokens sold to investor
        totalSupply = SafeMath.safeSub(totalSupply, tokens);
        // transfer tokens to investor
        exchangeContract.addShares(wallet, address(this), int256(tokens));
        // increaed the outstanding shares
        OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
        // check if funding round is complete?
        if (OUTSTANDING_SHARES == MAX_OFFERING_SHARES && totalSupply == 0) {
            TRADING_ACTIVE = true; // funding round is complete, secondary trading round is active! Use OrderBook for trading.
        }
        // post transfer event on the private blockchain
        emit Transfer(issuer, wallet, tokens);

        // save CAT
        string memory eventData = string(abi.encodePacked("FROM: ", issuer, ", TO: ", wallet, ", AMOUNT: ", exchangeContract.uintToString(tokens)));
        exchangeContract.addAuditEntry(symbol,exchangeContract.timestampToString(),"Transfer Token",eventData);
    }

    /**
     * Sell is when an investor wishes to liquidate their holdings
     */
    function sell(address wallet,uint256 certificateNo,uint256 tokens) external isOwner {
        require(exchangeContract.getInvestorStatus(wallet),"NW");
        require(tokens > 0, "NSF");
        require(certificateNo > 0,"not valid certificate no");
        require(findJurisdiction(exchangeContract.getInvestorJurisdiction(wallet)),"OOJ");
        require(exchangeContract.getShares(wallet,address(this)) >= int256(tokens),"NSF");
        require(exchangeContract.getInvestorStatus(wallet),"NRX");

        uint256 _price = 0;

        if (TRADING_ACTIVE) {
            // if trading is active, get current price from order book?
            (bid, ask) = exchangeContract.quote(symbol);
            if (ask > 0) {
                _price = ask;
            } else {
                _price = price;
            }
        }  

        if (wallet != issuer) {
            require (block.timestamp >= (transfer_log[wallet] + SIXMONTHS),"237.147(e)");
        }

        // Calculate the total fee amount
        uint256 Fee = (exchangeContract.usdToWei(SafeMath.safeMul(_price,tokens)) * FeePercentage) / 100;
        

        if (Fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",symbol," token")),int256(Fee),int256(Fee));
        }
        // transfer tokens to issuer and update totalSupply
        exchangeContract.transferShares(wallet,issuer,address(this),int256(tokens));
        totalSupply = SafeMath.safeAdd(totalSupply, tokens);
        // increaed the outstanding shares
        OUTSTANDING_SHARES = SafeMath.safeSub(OUTSTANDING_SHARES, tokens);
        // post transfer event on the private blockchain
        emit Transfer(wallet, issuer, tokens);

        // save CAT
        string memory eventData = string(abi.encodePacked("FROM: ", wallet, ", TO: ", issuer, ", AMOUNT: ", exchangeContract.uintToString(tokens)));
        exchangeContract.addAuditEntry(symbol,exchangeContract.timestampToString(),"Transfer Token",eventData);
    }



    /**
     * INTERNAL FUNCTIONS
     */
    function validate(address from,address to,uint tokens) external view override isOwner returns (bool) {
        int valid = 0;
        if (TRANSFERS_ACTIVE == false) {
            valid--;
        }
        if (!findJurisdiction(exchangeContract.getInvestorJurisdiction(from))) {
            valid--;
        }
        if (!findJurisdiction(exchangeContract.getInvestorJurisdiction(to))) {
            valid--;
        }
        if (!exchangeContract.getInvestorStatus(to)) {
            valid--;
        }
        if (tokens == 0) {
            valid--;
        }
        if (tokens > totalSupply) {
            valid--;
        }
        if (valid == 0) {
            return true;
        }
        return false;
    }

    function findJurisdiction(string memory jurisdiction) internal view returns(bool) {
        bool found = false;
        if (keccak256(bytes(homeJurisdiction)) == keccak256(bytes(jurisdiction))) {
            found = true;
        }            
        return found;
    }
}