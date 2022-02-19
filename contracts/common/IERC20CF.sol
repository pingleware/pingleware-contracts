// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract IERC20CF {
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address account) virtual public view returns (uint256);
    function allowance(address owner, address spender) virtual public view returns (uint256);
    function transfer(address recipient, uint256 amount) virtual public returns (bool);
    function approve(address spender, uint256 amount) virtual public returns (bool);
    function transferFrom(address sender, address recipient, uint256 tokens) virtual public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Buyerlist(address indexed tokenHolder);
    event issueDivi(address indexed tokenHolder,uint256 amount);
    event startSale(uint256 fromtime,uint256 totime,uint256 rate,uint256 supply);
}