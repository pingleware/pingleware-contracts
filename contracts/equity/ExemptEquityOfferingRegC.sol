// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Regulation Crowdfunding; Section 4(a)(6)
 * ----------------------------------------
 * See https://www.sec.gov/info/smallbus/secg/rccomplianceguide-051316.htm
 *
 * c. Transactions Conducted Through an Intermediary
 *
 * Each Regulation Crowdfunding offering must be exclusively conducted through one online platform. The intermediary operating the platform must be a broker-dealer
 * or a funding portal that is registered with the SEC and FINRA.
 *
 * Issuers may rely on the efforts of the intermediary to determine that the aggregate amount of securities purchased by an investor does not cause the investor
 * to exceed the investment limits, so long as the issuer does not have knowledge that the investor would exceed the investment limits as a result of purchasing
 * securities in the issuer’s offering.
 */

// IMPORTANT NOTE: BECUASE OF THE REGULATIONS FOR CROWD FUNDING MUST BE CONDUCTED THROUGH AN INTERMEDIATARY THAT IS REGISTERED AS A BROKER-DEAKER OR FUNDING PORTAL WITH
// THE SEC AND FINRA, THIS CROWDFUNDING TOKEN IS USEFUL FOR ONLY A REGISTERED BROKER-DEALER OR FUNDING PORTAL THAT DESIRES TO OFFER A CRYPTOCURRENCY.

// An example of a crowdfunding token at https://github.com/JincorTech/ico/blob/master/contracts/JincorToken.sol

contract ExemptEquityOfferingRegC {
    string public constant name = "Crowdfunding Token";
    string public constant symbol = "TOKEN.CF";
    uint8 public constant decimals = 0;
    uint256 public totalSupply = 0;

    uint256 public constant negative = type(uint256).max;

    uint256 public constant INITIAL_SUPPLY = 100000 * 1 ether;

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    address private owner;

    /* The finalizer contract that allows unlift the transfer limits on this token */
    address public releaseAgent;

    /** A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.*/
    bool public released = false;

    /** Map of agents that are allowed to transfer tokens regardless of the lock down period. These are crowdsale contracts and possible the team multisig itself. */
    mapping(address => bytes32) private verified;
    mapping(address => address) private cancellations;
    mapping(address => uint256) private holderIndices;
    mapping(address => bool) private transferAgents;
    mapping(address => uint256) private minters;
    mapping(address => mapping(address => uint256)) private _allowances;

    address[] private shareholders;

    bool internal active = false;
    uint256 private start_timestamp;

    mapping (address => uint256) public balances;

    event ExemptOffering(address indexed from,string status, uint256 value);
    event Transfer(address addr, uint256 amount);
    event TransferFrom(address from,address to,uint256 value);
    event TransferAgentAdded(address addr);
    event TransferAgentRemoved(address addr);
    event MinterAdded(address addr);
    event Minted(address addr, uint256 amount);
    event VerifiedAddressSuperseded(address addr1,address addr2,address addr3);
    event VerifiedAddressUpdated(address addr, bytes32 oldhash, bytes32 hash, address sender);
    event VerifiedAddressRemoved(address addr, address sender);
    event VerifiedAddressAdded(address addr, bytes32 hash, address sender);
    event Bought(uint value);
    event Sold(uint value);

    uint constant public parValue = 5 * 0.001 ether;
    uint constant public totalValueMax = 100000 * parValue;
    uint private totalValue = 0;

    uint256 private contract_creation; // The contract creation time

    bool private restricted = false;

    uint private year = 52 weeks;
    uint private sixmonths = 26 weeks;

      /**
       * @dev Constructor that gives msg.sender all of existing tokens.
       */
    constructor()
    {
        balances[msg.sender] = INITIAL_SUPPLY;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    modifier isMinter() {
      require(minters[msg.sender] == 1,"not a minter");
      _;
    }


    modifier isActive() {
        require(active, "exempt offering is not active");
        _;
    }

    modifier isVerifiedAddress(address addr) {
        require(verified[addr] != ZERO_BYTES, "");
        _;
    }

    /**
    * Limit token transfer until the crowdsale is over.
    *
    */
    modifier canTransfer(address _sender) {
        require(released || transferAgents[_sender], "");
        _;
    }

    /** The function can be called only before or after the tokens have been released */
    modifier inReleaseState(bool releaseState) {
        require(releaseState == released, "");
        _;
    }

    /** The function can be called only by a whitelisted release agent. */
    modifier onlyReleaseAgent() {
        require(msg.sender == releaseAgent, "");
        _;
    }




    /**
    * Set the contract that can call release and make the token transferable.
    *
    * Design choice. Allow reset the release agent to fix fat finger mistakes.
    */
    function setReleaseAgent(address addr) public onlyOwner inReleaseState(false) {
        require(addr != ZERO_ADDRESS, "");

        // We don't do interface check here as we might want to a normal wallet address to act as a release agent
        releaseAgent = addr;
    }

    function release() public onlyReleaseAgent inReleaseState(false) {
        released = true;
    }

    /**
    * Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
    */
    function setTransferAgent(address addr, bool state) public onlyOwner inReleaseState(false) {
        require(addr != ZERO_ADDRESS, "");
        transferAgents[addr] = state;
    }

    function transfer(address _to, uint _value) public canTransfer(msg.sender) returns (bool success) {
        // Call Burnable.transfer()
        return _transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public canTransfer(_from) returns (bool success) {
        // Call Burnable.transferForm()
        return _transferFrom(_from, _to, _value);
    }

    function burn(uint _value) public onlyOwner returns (bool success) {
        return _burn(_value);
    }

    function burnFrom(address _from, uint _value) public onlyOwner returns (bool success) {
        return _burnFrom(_from, _value);
    }

    // Internal
    function _mint(address addr, uint256 amount)
      internal
      returns (bool)
    {
      require(amount <= totalSupply, "exceeds total supply");
      balances[addr] += amount;
      emit Minted(addr, amount);
      return true;
    }

    function _transfer(address addr, uint256 amount)
      internal
      returns (bool)
    {
      balances[addr] = amount;
      emit Transfer(addr, amount);
      return true;
    }

    function _transferFrom(address from,address to,uint256 value)
      internal
      returns (bool)
    {
      require(balances[from] > value, "insufficient balance");
      balances[to] += value;
      balances[from] -= value;
      emit TransferFrom(from, to, value);
      return true;
    }

    function _burn(uint256 value)
      internal
      returns (bool)
    {
      require(totalSupply > value, "insufficient balance");
      totalSupply -= value;
      return true;
    }

    function _burnFrom(address _from,uint256 _value)
      internal
      returns (bool)
    {
      require(balances[_from] > _value, "insufficient balance");
      balances[_from] -= _value;
      return true;
    }
}
