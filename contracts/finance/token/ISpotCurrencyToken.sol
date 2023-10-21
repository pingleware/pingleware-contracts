// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


abstract contract ISpotCurrencyToken {
    struct INVESTOR_struct {
        address wallet;
        bool active;
        string jurisdiction;
        uint level;
    }

    address public owner;
    address public issuer;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public mintingFeePercentage;
    
    mapping(address => uint256) public balances;
    mapping(address => INVESTOR_struct) public whitelisted;
    mapping(address => bool) public transferAgents;
    mapping(address => uint256) public allocation;
    mapping(address => uint256) public deallocation;
    mapping(address => uint256) public transfer_allocation;

    address[] _whitelisted;
    address[] _transferAgents;

    string[] jurisdictions;

    uint256 totalWhitelisted = 0;
    uint256 totalTransferAgents = 0;

    // the gold reserves and token are 1:1, while the gold reserves are represented in decimals, this value is multiplied by 100
    uint256 public goldReserves = 0;

    // Event emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Withdrawal(address indexed recipient, uint256 amount);
    event Deposit(address indexed sender, uint256 amount);

    function findJurisdiction(string memory jurisdiction) virtual public view returns(bool);
    function addJurisdiction(string memory jurisdiction) virtual external;
    function addTransferAgent(address wallet) virtual public;
    function addWhitelister(address wallet,uint256 investor_type,string memory jurisdiction) virtual public;
    function checkWhitelisted() virtual public view returns (bool);
    function checkTransferAgent() virtual public view returns (bool);
    function getIssuer() virtual public view returns (address);
    function getBalance() virtual public view returns (uint256); 
    function getBalanceFrom(address wallet) virtual public view returns (uint256); 
    function increaseGoldReserves(uint256 amount) virtual public;
    function reduceGoldReserves(uint256 amount) virtual public;
    function addTraderAllocation(address wallet,uint256 amount) virtual public;
    function addTraderDeallocation(address wallet,uint256 amount) virtual public;
    function updateTransferAllocation(address issuer,address wallet,uint256 amount) virtual public;
    function mint(uint256 _value) virtual public payable;
    function burn(address wallet,uint256 _value) virtual public;
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool);
    function withdraw(uint256 _amount) virtual public;
}