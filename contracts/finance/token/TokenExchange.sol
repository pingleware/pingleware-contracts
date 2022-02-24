// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract BaseToken {
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

contract TokenExchange {
    string public constant name = "Token Exchange";
    string public constant symbol = "TKEX";

    event TokenPurchased(address sender, address token, uint amount, uint rate);
    event TokenSold(address sender, address token, uint amount, uint rate);

    BaseToken private token;

    function buy(address _token, uint _rate) public payable {
        // Ensure token address exists?
        require(_token != address(0), "undefined token");
        // Ensure sender wallet is valid, non-zero
        require(msg.sender != address(0), "zero wallets not accepted");
        // Check rate?
        require(_rate > 0, "rate must be positive");
        token = BaseToken(_token); // polymorphism in solidity
        uint tokenAmount = msg.value * _rate;
        if (token.owner.address != address(0)) {
            require(token.balanceOf(token.owner.address) >= tokenAmount, "excessive purchase amount request from token owner");
            token.approve(msg.sender, tokenAmount);
            token.transferFrom(payable(token.owner.address), msg.sender, tokenAmount);
            emit TokenPurchased(msg.sender,token.owner.address,tokenAmount,_rate);
        } else {
            // Ensure token contract balance has enough tokens
            require(token.balanceOf(address(token)) >= tokenAmount, "excessive purchase amount request from token contract");
            token.approve(msg.sender, tokenAmount);
            token.transferFrom(payable(address(token)), msg.sender, tokenAmount);
            emit TokenPurchased(msg.sender,address(token),tokenAmount,_rate);
        }
    }

    function sell(address _token, uint _amount, uint _rate) public payable {
        // Ensure token address exists?
        require(_token != address(0), "undefined token");
        // Ensure sender wallet is valid, non-zero
        require(msg.sender != address(0), "zero wallets not accepted");
         // Ensure sender balance has enough tokens
        require(token.balanceOf(msg.sender) >= _amount, "insufficient token balance");
        // Check rate?
        require(_rate > 0, "rate must be positive");

        uint etherAmount = _amount / _rate;
        payable(msg.sender).transfer(etherAmount);

        token = BaseToken(_token); // polymorphism in solidity
        if (token.owner.address != address(0)) {
            require(token.owner.address.balance >= etherAmount, "insufficient balance on token owner to send ether");
            token.approve(token.owner.address, _amount);
            // if token owner wallet exist, trasnfer to token owner
            token.transferFrom(msg.sender, payable(token.owner.address), _amount);
            emit TokenSold(msg.sender,address(token.owner.address),_amount,_rate);
        } else {
            require(address(token).balance >= etherAmount, "insufficient balance on token to send ether");
            token.approve(address(token), _amount);
            // otherwise, transfer to contract
            token.transferFrom(msg.sender, payable(address(token)), _amount);
            emit TokenSold(msg.sender,address(token),_amount,_rate);
        }
    }
}