// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IPaymentWallet.sol";
import "../../abstract/AEquityToken.sol";

contract RegAT1Equity is AEquityToken {
    string public homeJurisdiction;
    uint256 public bid = 0;
    uint256 public ask = 0;

    uint256 lastCertificateAssigned = 0;

    address public issuer;

    event ValueTransferred(address, uint256);
    event Approval(address,address,uint256);
    event Disapproval(address indexed investor, uint tokens, string reason);
    event Request(address investor,uint tokens,bool buy);

    constructor(address tokenIssuer,string memory jurisdiction,string memory tokenName,string memory tokenSymbol,uint256 tokenSupply,uint256 tokenPrice) {
        issuer = tokenIssuer;

        homeJurisdiction = jurisdiction;
        name = tokenName;
        symbol = tokenSymbol;
        totalSupply = tokenSupply;
        price = tokenPrice;

        MAX_OFFERING_SHARES = tokenSupply; // a maximum offering is set, to permit immediate resales after the funding round has been complete.
    }

    IPaymentWallet paymentWalletContract;

    function setPaymentWalletContract(address paymentWalletAddress) external {
        paymentWalletContract = IPaymentWallet(paymentWalletAddress);
    }

    function validate(address from,address to,uint tokens) public view returns (bool) {
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
        if (tokens > totalSupply) {
            valid--;
        }
        if (valid == 0) {
            return true;
        }
        return false;
    }

    function transfer(address from,address to, uint tokens)  external returns (bool) {
        require(from == msg.sender,"not from msg.sender");
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        paymentWalletContract.transfer(to,tokens,paymentWalletContract.getCVV());
        return true;
    }
    function transferFrom(address from, address to, uint tokens)  external returns (bool) {
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        paymentWalletContract.transferFrom(from, to, tokens, "N/A");
        return true;
    }
    function getBalanceFrom(address wallet) external view returns (uint256) {
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        return paymentWalletContract.getBalance(wallet);
    }
    function getIssuer() external view returns (address) {
        return issuer;
    }

     function buy(address wallet,uint256 tokens,uint256 fee) external {
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        uint256 amount = SafeMath.safeMul(tokens,price);
        paymentWalletContract.transfer(wallet, amount, paymentWalletContract.getCVV());
        fee;
     }    
}
