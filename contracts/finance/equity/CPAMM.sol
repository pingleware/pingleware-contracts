// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

// See https://www.youtube.com/watch?v=JSZbvmyi_LE

import "./PRESSPAGE506C.sol";

contract CPAMM {
    PRESSPAGE506C public immutable restrictedToken;
    PRESSPAGE506C public immutable unrestrictedToken;

    uint public reserve0;
    uint public reserve1;

    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => bool) public liquidityProviders;

    address public owner;

    constructor(address _restrictedToken, address _unrestrictedToken) {
        restrictedToken = PRESSPAGE506C(_restrictedToken);
        unrestrictedToken = PRESSPAGE506C(_unrestrictedToken);
        owner = msg.sender;
    }

    modifier isLiquidityProvider() {
        require(liquidityProviders[msg.sender] == true,"not a liquidity provider");
        _;
    }

    modifier isBalanceSufficient(address token, uint amount) {
        require(token[msg.sender].balanceOf() > amount, "insufficient token balance of liquidity provider");
        _;
    }

    modifier isOwner() {
        require(owner == msg.sender, "Not the contract owner");
        _;
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += amount;
        totalSupply += amount;
    }

    function _burn(address _from, uint _amount) private {
        require(totalSupply >= _amount,"attempt to burn more than minnted");
        balanceOf[_from] -= amount;
        totalSupply -= amount;
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
    function swap(address _tokenIn, uint _amountIn) external returns (uint amountOut) {
        require(_tokenIn == address(restrictedToken) || _tokenIn == address(token2),"invalid token");

        // Pull in token in
        bool isRestrictedToken = tokenIn == address(restrictedToken);
        (PRESSPAGE506C tokenId, PRESSPAGE506C tokenOut, uint reserveIn, unit reserveOut) = 
        isRestrictedToken ? 
        (restrictedToken,unrestrictedToken,reserve0,reserve1):
        (unrestrictedToken,restrictedToken,reserve1,reserve0);

        tokenIn.transferFrom(msg.sender, address(this), amountIn);

        // Calculate token out (include fees), fee 0.3%
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = ();
        // Transfer token out to msg.sender
        tokenOut.transfer(msg.sender, amountOut);
        // Update reserves
    }

    function addLiquidity() isLiquidityProvider external {
        // verify sender is a whitelisted liquidity provider
        // pull in restrictedToken and token 1
        // mint shares 
        // uodate reserves
    }

    function removeLiquidity() isLiquidityProvider external {}
}