// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IPaymentWallet {
    struct Wallet {
        address owner;
        uint256 balance;
        uint256 expirationDate;
        uint256 cvvCode;
    }

    function transfer(address to,uint256 amount,uint256 cvv) external;
    function transferFrom(address from,address to, uint256 amount,string calldata reason) external;
    function getCVV() external view returns (uint256);
    function getBalance(address wallet) external view returns (uint256);
    function deposit(address wallet,uint256 amount) external;

    event DepositMade(address,address,uint256);
    event Withdrawal(uint256);
    event Transferred(address,uint256);
    event FincenSARS(address,address,uint256,string);
    event AdminTransfer(address,address,uint256,string);

}