// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../libs/SafeMath.sol";
import "../interfaces/IConsolidatedAuditTrail.sol";
import "../interfaces/IOffering.sol";
import "../interfaces/IPaymentWallet.sol";
import "../interfaces/IExchange.sol";
import "./AAccessControl.sol";

abstract contract AToken is IOffering, AAccessControl {
    uint256 constant public SIXMONTHS = 180 days;
    uint256 constant public YEAR = 365 days;

    bool public TRANSFERS_ACTIVE    =   false;
    bool public TRADING_ACTIVE = false;

    uint256 public OUTSTANDING_SHARES = 0;
    uint256 public MAX_AFFILIATE_TRANSFER_SHARES = 0;
    uint256 public MAX_OFFERING_SHARES = 0;

    string public homeJurisdiction;
    string[] public jurisdictions;
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public price;

    IPaymentWallet paymentWalletContract;

    bool public restricted = false; 

    IExchange public exchangeContract;

    string public offeringType = "EQUITY";

    address public issuer;

    mapping(address => uint256) public transfer_log;

    uint256 FeePercentage = 1;
    address public feeRecipient;

    mapping(address => uint256) public balanceOf;

    receive() external payable {
        balanceOf[address(this)] += msg.value;
    }

    function validate(address from,address to,uint tokens) external view override returns (bool) {
        int valid = 0;
        if (TRANSFERS_ACTIVE == false) {
            valid--;
        }
        if (from == address(0x0)) {
            valid--;
        }
        if (to == address(0x0)) {
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

    function transferOnChainPurchase(address from, address to, uint tokens) external isOwner validDestination(to) {
        // Calculate the total fee amount
        uint256 Fee = (exchangeContract.usdToWei(SafeMath.safeMul(price,tokens)) * FeePercentage) / 100;

        if (Fee > 0) {
            exchangeContract.addEntry(block.timestamp,"Cash","RCEX Fee",string(abi.encodePacked("RCEX Fee for ",symbol," token")),int256(Fee),int256(Fee));
        }

        transfer(from,to,tokens);
    }

    function transfer(address from,address to, uint tokens) validDestination(to) public virtual override returns (bool) {
        require(from == msg.sender,"not from msg.sender");
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        if (exchangeContract.isAffiliate(msg.sender) && restricted) {
            require(tokens <= MAX_AFFILIATE_TRANSFER_SHARES,"exceed 10% of outstanding shares");
            MAX_AFFILIATE_TRANSFER_SHARES = SafeMath.safeSub(MAX_AFFILIATE_TRANSFER_SHARES, tokens);
        }
        paymentWalletContract.transfer(to,tokens,paymentWalletContract.getCVV());
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public validDestination(to) isOwner returns (bool success) {
        //require(validate(from, to, tokens),"not valid");
        if (address(paymentWalletContract) != address(0x0)) {
            paymentWalletContract.transferFrom(from, to, tokens, "N/A");
        } else {
            if (from != issuer) {
                require (block.timestamp >= (transfer_log[from] + SIXMONTHS),"237.147(e)");
                require (keccak256(abi.encodePacked(exchangeContract.getInvestorJurisdiction(from))) ==  keccak256(abi.encodePacked(exchangeContract.getInvestorJurisdiction(to))),"cannot be sold across jursidcitons");
            }
            if (exchangeContract.isTransferAgent(from)) {
                OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
                MAX_AFFILIATE_TRANSFER_SHARES = SafeMath.safeDiv(OUTSTANDING_SHARES, 10);
            }

            if (exchangeContract.isAffiliate(from) && restricted) {
                require(tokens <= MAX_AFFILIATE_TRANSFER_SHARES,"exceed 10% of outstanding shares");
                OUTSTANDING_SHARES = SafeMath.safeAdd(OUTSTANDING_SHARES, tokens);
                MAX_AFFILIATE_TRANSFER_SHARES = SafeMath.safeSub(MAX_AFFILIATE_TRANSFER_SHARES, tokens);
            }

            exchangeContract.transferShares(from, to, address(this), int256(tokens));
            transfer_log[to] = block.timestamp;

            emit Transfer(from, to, tokens);

            // save CAT
            string memory eventData = string(abi.encodePacked("FROM: ", from, ", TO: ", to, ", AMOUNT: ", exchangeContract.uintToString(tokens)));
            exchangeContract.addAuditEntry(symbol,exchangeContract.timestampToString(),IConsolidatedAuditTrail.REPORTABLE_EVENT.ORDER_EXECUTED,eventData);
        }

        return true;
    }


    function setExchangeContract(address exchangeAddress) external {
        exchangeContract = IExchange(exchangeAddress);
    }

    function setOfferingType(string memory _offeringType) external {
        offeringType = _offeringType;
    }

    function setTokenIssuer(address wallet) external {
        issuer = wallet;
    }
    function setPaymentWalletContract(address paymentWalletAddress) external {
        paymentWalletContract = IPaymentWallet(paymentWalletAddress);
    }
    function changeTradingStatus(bool status,string calldata reason) external {
        TRADING_ACTIVE = status;
        emit TradingStatusChanged(status,reason);
    }
    function changeTransferStatus(bool status,string calldata reason) external {
        TRANSFERS_ACTIVE = status;
        emit TransferStatusChanged(status,reason);
    } 
    function getSymbol() external view returns(string memory) {
        return name;
    }
    function getIssuer() external view returns (address) {
        return issuer;
    }
    function getOutstandingShares() external view returns (uint256) {
        return OUTSTANDING_SHARES;
    }
    function getTotalSupply() external view returns (uint256) {
        return MAX_OFFERING_SHARES;
    }
    function getOfferingType() external view returns (string memory) {
        return offeringType;
    } 
    function getMaxOfferingShares() external view returns (uint256) {
        return MAX_OFFERING_SHARES;
    }
    function findJurisdiction(string memory jurisdiction) internal view returns(bool) {
        bool found = false;
        for(uint i=0; i<jurisdictions.length; i++) {
            if (keccak256(bytes(jurisdictions[i])) == keccak256(bytes(jurisdiction))) {
                found = true;
                break;
            }
        }
        return found;
    }
    function getBalanceFrom(address wallet) external view returns (uint256) {
        if (address(paymentWalletContract) != address(0x0)) {
            return paymentWalletContract.getBalance(wallet);
        } 
        return uint256(exchangeContract.getShares(wallet,address(this)));
    }

    function addInvestor(address wallet) external virtual isOwner {
        require(findJurisdiction(exchangeContract.getInvestorJurisdiction(wallet)),"out of jurisdiction");
        exchangeContract.addInvestor(symbol, wallet);
    }

    function addJurisdiction(string calldata jurisdiction) external isOwner {
        if (findJurisdiction(jurisdiction) == false) {
            jurisdictions.push(jurisdiction);
        }
    }

    function setFeeRecipient(address wallet) external isOwner {
        feeRecipient = wallet;
    }

    function getTradingStatus() external view returns(bool) {
        return TRADING_ACTIVE;
    }
}