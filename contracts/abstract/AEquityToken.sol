// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../interfaces/IEquityToken.sol";
import "./AToken.sol";

abstract contract AEquityToken is AToken, IEquityToken {
    uint256 public volume = 0;
    uint256 public bid = 0;
    uint256 public ask = 0;
    uint256 public high = 0;
    uint256 public low = 0;

    uint256 lastCertificateAssigned = 0;

    event ValueTransferred(address, uint256);
    event Approval(address,address,uint256);
    event Disapproval(address indexed investor, uint tokens, string reason);
    event Request(address investor,uint tokens,bool buy);

    function getName() external view returns (string memory) {
        return name;
    }

    /**
     * Needed to calculate the Exchange Market Index
     * Total Exchange Market Value = sum of each offering market value [getMarketValue()]
     * Exchange Market Index = sum of the product of the offering price and offering merket weigth
     */
    function getMarketValue() external view returns (uint256) {
        return SafeMath.safeMul(price, OUTSTANDING_SHARES);
    }

    function getMarketWeight(uint256 totalExchangeMarketValue) external view returns (uint256) {
        // normalized to account for decimals
        return SafeMath.safeMul(SafeMath.safeDiv(SafeMath.safeMul(price, OUTSTANDING_SHARES),totalExchangeMarketValue),100);
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    function purchaseShares(address wallet,uint256 tokens,uint256 Fee) public virtual {
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
        string memory eventData = exchangeContract.formatEventDataForOrderRouting(string(abi.encodePacked(blockhash(block.timestamp))), string(abi.encodePacked(issuer)), string(abi.encodePacked(wallet)), string(abi.encodePacked(block.timestamp)), string(abi.encodePacked(block.timestamp)), exchangeContract.uintToString(tokens), "");
        exchangeContract.addAuditEntry(symbol,exchangeContract.timestampToString(),IConsolidatedAuditTrail.REPORABLE_EVENT.ORDER_ROUTING,eventData);
    }

    /**
     * Sell is when an investor wishes to liquidate their holdings
     */
    function sellShares(address wallet,uint256 certificateNo,uint256 tokens) public virtual {
        require(exchangeContract.getInvestorStatus(wallet),"NW");
        require(tokens > 0, "NSF");
        require(certificateNo > 0,"not valid certificate no");
        require(findJurisdiction(exchangeContract.getInvestorJurisdiction(wallet)),"OOJ");
        require(exchangeContract.getShares(wallet,address(this)) >= int256(tokens),"NSF");
        require(exchangeContract.getInvestorStatus(wallet),"NRX");

        uint256 _price = 0;

        if (TRADING_ACTIVE) {
            // if trading is active, get current price from order book?
            (volume, bid, ask, high, low) = exchangeContract.quote(symbol);
            if (ask > 0) {
                _price = ask;
            } else {
                _price = price;
            }
        }  

        if (wallet != issuer) {
            require (block.timestamp >= (transfer_log[wallet] + SIXMONTHS),"237.147(e)");
        }
        if (exchangeContract.isAffiliate(wallet)) {
            require(tokens <= MAX_AFFILIATE_TRANSFER_SHARES,"exceed 10% of OUTSTANDING SHARES");
            OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
            MAX_AFFILIATE_TRANSFER_SHARES = SafeMath.safeSub(MAX_AFFILIATE_TRANSFER_SHARES, tokens);
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
        if (exchangeContract.isAffiliate(wallet) && restricted) {
            require(tokens <= MAX_AFFILIATE_TRANSFER_SHARES,"exceed 10% of OUTSTANDING SHARES");
            OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
            MAX_AFFILIATE_TRANSFER_SHARES = SafeMath.safeSub(MAX_AFFILIATE_TRANSFER_SHARES, tokens);
        } else {
            OUTSTANDING_SHARES = SafeMath.safeSub(OUTSTANDING_SHARES, tokens);
        }
        // post transfer event on the private blockchain
        emit Transfer(wallet, issuer, tokens);

        // save CAT
        string memory eventData = exchangeContract.formatEventDataForOrderRouting(string(abi.encodePacked(blockhash(block.timestamp))), string(abi.encodePacked(wallet)), string(abi.encodePacked(issuer)), string(abi.encodePacked(block.timestamp)), string(abi.encodePacked(block.timestamp)), exchangeContract.uintToString(tokens), "");
        exchangeContract.addAuditEntry(symbol,exchangeContract.timestampToString(),IConsolidatedAuditTrail.REPORABLE_EVENT.ORDER_ROUTING,eventData);
    }
}