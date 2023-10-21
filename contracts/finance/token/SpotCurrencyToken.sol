// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./ISpotCurrencyToken.sol";

// This contract represents a spot currency token based on gold
contract SpotCurrencyToken is ISpotCurrencyToken {

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply,
        address _owner,
        address _issuer,
        uint256 _mintingFeePercentage
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        issuer = _issuer;
        owner = _owner;
        mintingFeePercentage = _mintingFeePercentage;
        transferAgents[issuer] = true;
    }

    modifier isOwner() {
        require(msg.sender == owner,"not authorized");
        _;
    }

    modifier isIssuer() {
        require(msg.sender == issuer,"not authorized issuer");
        _;
    }

    modifier isTransferAgent() {
        require(transferAgents[msg.sender],"Not a transfer agent");
        _;
    }

    modifier isJurisdiction() {
        require(findJurisdiction(whitelisted[msg.sender].jurisdiction),"not authorized for the jurisdiction");
        _;
    }


    modifier isWhitelisted() {
        require(whitelisted[msg.sender].active,"not authorized to mint tokens");
        _;
    }

    function findJurisdiction(string memory jurisdiction) public override view returns(bool) {
        bool found = false;
        for (uint i=0; i<jurisdictions.length; i++) {
            if (keccak256(bytes(jurisdictions[i])) == keccak256(bytes(jurisdiction))) {
                found = true;
            }            
        }
        return found;
    }

    function addJurisdiction(string memory jurisdiction) override external {
        bool found = findJurisdiction(jurisdiction);
        require(found == false,"jurisdiction has already been added");
        jurisdictions.push(jurisdiction);
    }


    function addTransferAgent(address wallet) public override isOwner {
        require(!transferAgents[wallet],"already a registered transfer agent");
        transferAgents[wallet] = true;
        _transferAgents.push(wallet);
        totalTransferAgents = _transferAgents.length;
    }

    function addWhitelister(address wallet,uint256 investor_type,string memory jurisdiction) public override isOwner {
        require(whitelisted[wallet].active == false,"already a registered trader");
        whitelisted[wallet] = INVESTOR_struct(wallet,true,jurisdiction,investor_type);
        _whitelisted.push(wallet);
        totalWhitelisted = _whitelisted.length;
    }

    function checkWhitelisted() public view override returns (bool) {
        return whitelisted[msg.sender].active;
    }

    function checkTransferAgent() public view override returns (bool) {
        return transferAgents[msg.sender];
    }

    function getIssuer() public view override returns (address) {
        return issuer;
    }

    function getBalance() public view override returns (uint256) {
        return balances[msg.sender];
    }

    function getBalanceFrom(address wallet) public view override returns (uint256) {
        return balances[wallet];
    }

    function increaseGoldReserves(uint256 amount) public override isIssuer {
        require((goldReserves + amount) <= totalSupply,"will exceed the total supply");
        goldReserves += amount;
    }

    function reduceGoldReserves(uint256 amount) public override isIssuer {
        require((goldReserves - amount) >= 0,"will create a gold reserves deficit");
        goldReserves -= amount;
    }

    function addTraderAllocation(address wallet,uint256 amount) public override isIssuer {
        require(whitelisted[wallet].active,"trader is not whitelisted");
        allocation[wallet] = amount;
    }
    function addTraderDeallocation(address wallet,uint256 amount) public override isIssuer {
        require(whitelisted[wallet].active,"trader is not whitelisted");
        deallocation[wallet] = amount;
    }
    function updateTransferAllocation(address _issuer,address wallet,uint256 amount) public override isIssuer {
        require(_issuer == issuer,"not authorized, invalid issuer");
        require(whitelisted[wallet].active,"trader is not whitelisted");
        transfer_allocation[wallet] = amount;
    }

    // off-chain, trader send amount to issuer through money transmitter like stripe, to buy tokens based on the gold spot price.
    // issuer will calculate the number of tokens from the amount submitted and gold spot price,
    // issuer will execute a trade on a forex broker to buy XAUUSD in the amount submitted by the trader
    // issuer will update the new gold reserves value by the additional tokens calculate above
    // issuer will update the SpotCurrencyToken contract for it's symbol, with the token allocation amount
    // trader can mint tokens at any time, a fee is added and added to the contract wallet balance, for the issuer to withdraw later
    //
    // minting is when adding tokens to totalSupply, because gold reserves have increase through a trader purchase
    // permits a buyer to buy more tokens, if there are enough gold reserves
    function mint(uint256 _value) public payable override isWhitelisted isJurisdiction {
        require(_value > 0, "Invalid value");
        uint256 total = getTotal(); // get the current total of minted tokens of all wallet balances
        require((_value + total) <= goldReserves,"not enough gold reserves"); // add the desired new amount to the total and verify enough gol reserves
        require(allocation[msg.sender] == _value,"invalid allocation amount for trader");

        // Calculate the amount to be minted (excluding the fee)
        uint256 mintAmount = _value;

        // Calculate the fee as a percentage of the minted value
        uint256 mintingFee = (_value * mintingFeePercentage) / 100;
        require(msg.value >= mintingFee, "Insufficient fee");

        // reset trader allocation
        allocation[msg.sender] = 0;

        // Transfer the fee to the contract
        payable(address(this)).transfer(mintingFee);

        // Mint the tokens (excluding the fee)
        balances[msg.sender] += mintAmount;

        emit Mint(msg.sender, mintAmount);
        emit Transfer(address(0), msg.sender, mintAmount);
    }

    // when a trader wishes to withdraw balance, they make an off-chain request for the amount to withdraw
    // issuer will verify there are no open trades for the trader
    // the issuer will sell XAUSD on the forex broker for the amount requested, with checking and validation
    // the issuer will calculate the tokens equivalent
    // the issuer will reduce the gold reserves by the tokens value calculate above
    // the issuer will set the trader dealloation amount
    // the issuer will burn the trader tokens
    //
    // burn is when removing tokens from the totalSupply, because a trader has withdrawn from the gold reserves
    function burn(address wallet, uint256 _value) public override isIssuer {
        require(wallet != address(0), "Invalid address");
        require(balances[wallet] >= _value, "Insufficient balance");
        require(_value > 0, "Invalid value");
        require(deallocation[wallet] == _value,"invalid deallocation amount for trader");

        deallocation[wallet] = 0;

        balances[wallet] -= _value;

        emit Burn(wallet, _value);
        emit Transfer(wallet, address(0), _value);
    }

    // Transfer tokens from the sender's address to another address
    function transferFrom(address _from, address _to, uint256 _value) public override isTransferAgent returns (bool) {
        require(_value <= balances[_from], "Insufficient balance");
        require(_to != address(0), "Invalid address");
        require(transfer_allocation[_from] == _value,"invalid transfer allocation");
        require(transfer_allocation[_to] == _value,"invalid transfer allocation");

        transfer_allocation[_from] = 0;
        transfer_allocation[_to] = 0;

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function withdraw(uint256 _amount) public override isIssuer {
        require(_amount > 0, "Invalid amount");
        require(_amount <= address(this).balance, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawal(msg.sender, _amount);
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function getTotal() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i=0; i < totalWhitelisted; i++) {
            total += balances[_whitelisted[i]];
        }
        return total;
    }
}
