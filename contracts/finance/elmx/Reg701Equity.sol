// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * Rule 701 - Employee benefit plans
 *
 * Rule 701 exempts certain sales of securities made to compensate employees, consultants and advisors. 
 * This exemption is not available to Exchange Act reporting companies. A company can sell at least $1 million of securities under this exemption, regardless of its size. 
 * A company can sell even more if it satisfies certain formulas based on its assets or on the number of its outstanding securities. 
 * If a company sells more than $10 million in securities in a 12-month period, it is required to provide certain financial and other disclosure to the persons that received securities in that period. 
 * Securities issued under Rule 701 are “restricted securities” and may not be freely traded unless the securities are registered or the holders can rely on an exemption.
 */

import "../../interfaces/IPaymentWallet.sol";
import "../../abstract/AEquityToken.sol";

contract Reg701Equity is AEquityToken {
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
        IPaymentWallet paymentWallet = IPaymentWallet(from);
        paymentWallet.transfer(to,tokens,paymentWallet.getCVV());
        return true;
    }
    function transferFrom(address from, address to, uint tokens)  external returns (bool) {
        IPaymentWallet paymentWallet = IPaymentWallet(from);
        paymentWallet.transferFrom(to, tokens, "N/A");
        return true;
    }
    function getBalanceFrom(address wallet) external view returns (uint256) {
        IPaymentWallet paymentWallet = IPaymentWallet(wallet);
        return paymentWallet.getBalance();
    }
    function getIssuer() external view returns (address) {
        return issuer;
    }

     function buy(address wallet,uint256 tokens,uint256 fee) external {
        IPaymentWallet paymentWallet = IPaymentWallet(wallet);
        uint256 amount = SafeMath.safeMul(tokens,price);
        paymentWallet.transfer(issuer, amount, paymentWallet.getCVV());
        fee;
     }
}