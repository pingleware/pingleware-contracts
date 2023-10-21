// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// See https://www.youtube.com/watch?v=JSZbvmyi_LE

import "../elmx/RegD506CEquity.sol";

contract CPAMM {
    RegD506CEquity public immutable restrictedToken;
    RegD506CEquity public immutable unrestrictedToken;

    uint public reserve0;
    uint public reserve1;

    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => bool) public liquidityProviders;

    address public owner;

    constructor(address _restrictedToken, address _unrestrictedToken) {
        restrictedToken = RegD506CEquity(_restrictedToken);
        unrestrictedToken = RegD506CEquity(_unrestrictedToken);
        owner = msg.sender;
    }

    modifier isLiquidityProvider() {
        require(liquidityProviders[msg.sender] == true,"not a liquidity provider");
        _;
    }

    modifier isBalanceSufficient(address token, uint amount) {
        //require(token[msg.sender].balanceOf() > amount, "insufficient token balance of liquidity provider");
        _;
    }

    modifier isOwner() {
        require(owner == msg.sender, "Not the contract owner");
        _;
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        require(totalSupply >= _amount,"attempt to burn more than minnted");
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function addLiquidityProvider(address _liquidityProvider) public isOwner {
        require(liquidityProviders[_liquidityProvider] == false,"already registered liquidity provider");
        liquidityProviders[_liquidityProvider] = true;
    }

    function buy(address _token, uint _amount) external {
        // check if sender is whitelisted on the token, so they can buy 
        // calculate token out (include fees), fee 0.3%
        // transfer token out to sender
        // update reserves
    }

    function sell(address _token, uint _amount) external {

    }

    // use to exchange a restricted token for an unrestricted, under Rule 144
    //
    function swap(address _tokenIn, uint _amountIn) external pure returns (uint amountOut) {
        //require(_tokenIn == address(restrictedToken) || _tokenIn == address(token2),"invalid token");
        _tokenIn;
        _amountIn;

        // Pull in token in
        // TODO: bool isRestrictedToken = _tokenIn == address(restrictedToken);
        // TODO: (RegD506CEquity tokenId, RegD506CEquity tokenOut, uint reserveIn, uint reserveOut) = 
        // TODO: isRestrictedToken ? 
        // TODO: (restrictedToken,unrestrictedToken,reserve0,reserve1):
        // TODO: (unrestrictedToken,restrictedToken,reserve1,reserve0);

        // TODO: tokenId.transferFrom(msg.sender, address(this), _amountIn);

        // Calculate token out (include fees), fee 0.3%
        // TODO: uint amountInWithFee = (_amountIn * 997) / 1000;
        // TODO: amountOut = ();
        // Transfer token out to msg.sender
        // TODO: tokenOut.transfer(msg.sender, amountOut);
        // Update reserves
        return 0;
    }
 
    function addLiquidity() isLiquidityProvider external {
        // verify sender is a whitelisted liquidity provider
        // pull in restrictedToken and token 1
        // mint shares 
        // uodate reserves
    }

    function removeLiquidity() isLiquidityProvider external {

    }
}