// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

import "../../interfaces/IPaymentWallet.sol";
import "../../abstract/ADebtToken.sol";

abstract contract Reg3A11Debt is ADebtToken {
 
    constructor() {

    }

    function validate(address from,address to,uint tokens) external view returns (bool) {
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
        if (tokens == 0) {
            valid--;
        }
        if (valid == 0) {
            return true;
        }
        return false;
    }
    function transfer(address from,address to, uint tokens)  external returns (bool) {
        IPaymentWallet(from).transfer(to, tokens, IPaymentWallet(from).getCVV());
        return true;
    }
    function transferFrom(address from, address to, uint tokens)  external returns (bool) {
        IPaymentWallet(from).transferFrom(to, tokens, "N/A");
        return true;
    }
    function getBalanceFrom(address wallet) external view returns (uint256) {
        return IPaymentWallet(wallet).getBalance();
    }
    function getTradingStatus() external view returns (bool) {
        return TRADING_ACTIVE;
    }
    function changeTradingStatus(bool) external {

    }

    function buy(address wallet,uint256 tokens,uint256 Fee) external {

    }

    function getIssuer() external view returns (address) {
        return issuer;
    }
    function getOutstandingShares() external view returns (uint256) {

    }
    function getTotalSupply() external view returns (uint256) {

    }
    function getOfferingType() external view returns (string memory) {

    }
}