// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 tokens) external returns (bool);

    function name() external returns (string memory);
    function symbol() external returns (string memory);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Buyerlist(address indexed tokenHolder);
    event issueDivi(address indexed tokenHolder,uint256 amount);
    event startSale(uint256 fromtime,uint256 totime,uint256 rate,uint256 supply);

}
