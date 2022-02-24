// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract IERC20TOKEN {
    address public owner;

    function totalSupply() virtual public view returns (uint);
    function balanceOf(address tokenOwner) virtual public view returns (uint);
    function allowance(address tokenOwner, address spender) virtual public view returns (uint);
    function transfer(address to, uint tokens) virtual public returns (bool);
    function approve(address spender, uint tokens) virtual public returns (bool);
    function transferFrom(address from, address to, uint tokens) virtual public returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}