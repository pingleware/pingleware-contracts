// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Rule 504 permits certain issuers to offer and sell up to $1 million of securities
 * in any 12-month period.  These securities may be sold to any number and
 * type of investor, and the issuer is not subject to specific disclosure requirements.
 * Generally, securities issued under Rule 504 will be restricted securities
 * (as further explained below), unless the offering meets certain additional requirements.
 * As a prospective investor, you should confirm with the issuer whether the securities
 * being offered under this rule will be restricted.
 */

import "../Version.sol";

contract ExemptEquityOffering504 is Version {
    string public constant name = "Rule 504 Token";
    string public constant symbol = "TOKEN.504";
    uint8 public constant decimals = 0;
    uint256 public totalSupply = 0;

    uint256 public constant negative = type(uint256).max;

    uint public constant INITIAL_SUPPLY = 100000 * 1 ether;

    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);


    mapping(address => bytes32) private verified;
    mapping(address => address) private cancellations;
    mapping(address => uint256) private holderIndices;
    mapping(address => uint256) public  balances;
    mapping(address => bool) private transferagents;
    mapping(address => uint256) private minters;
    mapping(address => mapping(address => uint256)) private _allowances;

    struct Transaction {
        address addr;
        uint256 amount;
        uint256 time;
    }

    mapping(address => Transaction[]) public transactions;

    address private owner;

    address[] private shareholders;

    bool internal active = false;
    uint256 private start_timestamp;
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

    uint constant public parValue = 5 * 0.001 ether;
    uint constant public totalValueMax = 100000 * parValue;
    uint private totalValue = 0;

    uint256 private contract_creation; // The contract creation time

    bool private restricted = true;

    uint private year = 52 weeks;
    uint private sixmonths = 26 weeks;

    event Bought(uint value);
    event Sold(uint value);

    constructor()
    {
        owner = msg.sender;
        addMinter(owner);
        _mint(owner, INITIAL_SUPPLY);
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

    modifier isShareholder(address addr) {
        require(holderIndices[addr] != 0, "");
        _;
    }

    modifier isNotShareholder(address addr) {
        require(holderIndices[addr] == 0, "");
        _;
    }

    modifier isNotCancelled(address addr) {
        require(cancellations[addr] == ZERO_ADDRESS, "");
        _;
    }

    function balanceOf(address addr)
      public
      view
      returns (uint256)
    {
      return balances[addr];
    }

    function allowance(address _owner, address spender)
      public
      view
      returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function addMinter(address addr)
      public
      onlyOwner
    {
      require(addr != ZERO_ADDRESS, "missing minter address");
      minters[addr] = 1;
      emit MinterAdded(addr);
    }

    function addTransferAgent(address addr)
        public
        onlyOwner
    {
        require(addr != ZERO_ADDRESS, "missing transfer agent address");
        transferagents[addr] = true;
        emit TransferAgentAdded(addr);
    }

    function removeTransferAgent(address addr)
        public
        onlyOwner
    {
        require(addr == ZERO_ADDRESS,"missing transfer agent address");
        require(addr != owner,"cannot remove the owner");
        transferagents[addr] = false;
        emit TransferAgentRemoved(addr);
    }

    /**
     * As each token is minted it is added to the shareholders array.
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
        public
        isActive
        onlyOwner
        isMinter
        isVerifiedAddress(_to)
        returns (bool)
    {
        // if the address does not already own share then
        // add the address to the shareholders array and record the index.
        updateShareholders(_to);
        return _mint(_to, _amount);
    }

    function toggleExemptOffering(uint256 timestamp, bool _active)
        public
        onlyOwner
    {
        start_timestamp = timestamp;
        active = _active;

        if (active) {
            emit ExemptOffering(msg.sender, string(abi.encodePacked(name, " has started")), timestamp);
        } else {
            emit ExemptOffering(msg.sender, string(abi.encodePacked(name, " has stopped")), timestamp);
        }
    }

    /**
     *  The number of addresses that own tokens.
     *  @return the number of unique addresses that own tokens.
     */
    function holderCount()
        public
        onlyOwner
        view
        returns (uint)
    {
        return shareholders.length;
    }

    /**
     *  By counting the number of token holders using `holderCount`
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if `index >= holderCount()`.
     *  @param index The zero-based index of the holder.
     *  @return the address of the token holder with the given index.
     */
    function holderAt(uint256 index)
        public
        onlyOwner
        view
        returns (address)
    {
        require(index < shareholders.length, "");
        return shareholders[index];
    }

    /**
     *  Add a verified address, along with an associated verification hash to the contract.
     *  Upon successful addition of a verified address, the contract must emit
     *  `VerifiedAddressAdded(addr, hash, msg.sender)`.
     *  It MUST throw if the supplied address or hash are zero, or if the address has already been supplied.
     *  @param addr The address of the person represented by the supplied hash.
     *  @param hash A cryptographic hash of the address holder's verified information.
     */
    function addVerified(address addr, bytes32 hash)
        public
        onlyOwner
        isNotCancelled(addr)
    {
        require(addr != ZERO_ADDRESS, "");
        require(hash != ZERO_BYTES, "");
        require(verified[addr] == ZERO_BYTES, "");
        verified[addr] = hash;
        emit VerifiedAddressAdded(addr, hash, msg.sender);
    }

    /**
     *  Remove a verified address, and the associated verification hash. If the address is
     *  unknown to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  It MUST throw if an attempt is made to remove a verifiedAddress that owns Tokens.
     *  @param addr The verified address to be removed.
     */
    function removeVerified(address addr)
        public
        onlyOwner
    {
        require(addr.balance == 0, "account balance is not zero");
        if (verified[addr] != ZERO_BYTES) {
            verified[addr] = ZERO_BYTES;
            emit VerifiedAddressRemoved(addr, msg.sender);
        }
    }

    /**
     *  Update the hash for a verified address known to the contract.
     *  Upon successful update of a verified address the contract must emit
     *  `VerifiedAddressUpdated(addr, oldHash, hash, msg.sender)`.
     *  If the hash is the same as the value already stored then
     *  no `VerifiedAddressUpdated` event is to be emitted.
     *  It MUST throw if the hash is zero, or if the address is unverified.
     *  @param addr The verified address of the person represented by the supplied hash.
     *  @param hash A new cryptographic hash of the address holder's updated verified information.
     */
    function updateVerified(address addr, bytes32 hash)
        public
        onlyOwner
        isVerifiedAddress(addr)
    {
        require(hash != ZERO_BYTES, "");
        bytes32 oldHash = verified[addr];
        if (oldHash != hash) {
            verified[addr] = hash;
            emit VerifiedAddressUpdated(addr, oldHash, hash, msg.sender);
        }
    }

    /**
     *  Cancel the original address and reissue the Tokens to the replacement address.
     *  Access to this function MUST be strictly controlled.
     *  The `original` address MUST be removed from the set of verified addresses.
     *  Throw if the `original` address supplied is not a shareholder.
     *  Throw if the replacement address is not a verified address.
     *  This function MUST emit the `VerifiedAddressSuperseded` event.
     *  @param original The address to be superseded. This address MUST NOT be reused.
     *  @param replacement The address  that supersedes the original. This address MUST be verified.
     */
    function cancelAndReissue(address original, address replacement)
        public
        isActive
        onlyOwner
        isShareholder(original)
        isNotShareholder(replacement)
        isVerifiedAddress(replacement)
    {
        // replace the original address in the shareholders array
        // and update all the associated mappings
        verified[original] = ZERO_BYTES;
        cancellations[original] = replacement;
        uint256 holderIndex = holderIndices[original] - 1;
        shareholders[holderIndex] = replacement;
        holderIndices[replacement] = holderIndices[original];
        holderIndices[original] = 0;
        balances[replacement] = balances[original];
        balances[original] = 0;
        emit VerifiedAddressSuperseded(original, replacement, msg.sender);
    }

    /**
     *  The `transfer` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `msg.sender`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transfer(address to, uint256 value)
        public
        isActive
        isVerifiedAddress(to)
        returns (bool)
    {
        updateShareholders(to);
        pruneShareholders(msg.sender, value);
        return _transfer(to, value);
    }

    /**
     *  The `transferFrom` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `from`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transferFrom(address from, address to, uint256 value)
        public
        isActive
        isVerifiedAddress(to)
        returns (bool)
    {
        updateShareholders(to);
        pruneShareholders(from, value);
        return _transferFrom(from, to, value);
    }

    /**
     *  Tests that the supplied address is known to the contract.
     *  @param addr The address to test.
     *  @return true if the address is known to the contract.
     */
    function isVerified(address addr)
        public
        view
        returns (bool)
    {
        return verified[addr] != ZERO_BYTES;
    }

    /**
     *  Checks to see if the supplied address is a share holder.
     *  @param addr The address to check.
     *  @return true if the supplied address owns a token.
     */
    function isHolder(address addr)
        public
        view
        returns (bool)
    {
        return holderIndices[addr] != 0;
    }

    /**
     *  Checks that the supplied hash is associated with the given address.
     *  @param addr The address to test.
     *  @param hash The hash to test.
     *  @return true if the hash matches the one supplied with the address in `addVerified`, or `updateVerified`.
     */
    function hasHash(address addr, bytes32 hash)
        public
        view
        returns (bool)
    {
        if (addr == ZERO_ADDRESS) {
            return false;
        }
        return verified[addr] == hash;
    }

    /**
     *  Checks to see if the supplied address was superseded.
     *  @param addr The address to check.
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr)
        public
        view
        onlyOwner
        returns (bool)
    {
        return cancellations[addr] != ZERO_ADDRESS;
    }

    /**
     *  Gets the most recent address, given a superseded one.
     *  Addresses may be superseded multiple times, so this function needs to
     *  follow the chain of addresses until it reaches the final, verified address.
     *  @param addr The superseded address.
     *  @return the verified address that ultimately holds the share.
     */
    function getCurrentFor(address addr)
        public
        view
        onlyOwner
        returns (address)
    {
        return findCurrentFor(addr);
    }

    /**
     *  Recursively find the most recent address given a superseded one.
     *  @param addr The superseded address.
     *  @return the verified address that ultimately holds the share.
     */
    function findCurrentFor(address addr)
        internal
        view
        returns (address)
    {
        address candidate = cancellations[addr];
        if (candidate == ZERO_ADDRESS) {
            return addr;
        }
        return findCurrentFor(candidate);
    }

    /**
     *  If the address is not in the `shareholders` array then push it
     *  and update the `holderIndices` mapping.
     *  @param addr The address to add as a shareholder if it's not already.
     */
    function updateShareholders(address addr)
        internal
    {
        if (holderIndices[addr] == 0) {
          shareholders.push(addr);
          holderIndices[addr] = 1;
        }
    }

    /**
     *  If the address is in the `shareholders` array and the forthcoming
     *  transfer or transferFrom will reduce their balance to 0, then
     *  we need to remove them from the shareholders array.
     *  @param addr The address to prune if their balance will be reduced to 0.
     @  @dev see https://ethereum.stackexchange.com/a/39311
     */
    function pruneShareholders(address addr, uint256 value)
        internal
    {
        uint256 balance = addr.balance - value;
        if (balance > 0) {
            return;
        }
        uint256 holderIndex = holderIndices[addr] - 1;
        uint256 lastIndex = shareholders.length - 1;
        address lastHolder = shareholders[lastIndex];
        // overwrite the addr's slot with the last shareholder
        shareholders[holderIndex] = lastHolder;
        // also copy over the index (thanks @mohoff for spotting this)
        // ref https://github.com/davesag/ERC884-reference-implementation/issues/20
        holderIndices[lastHolder] = holderIndices[addr];
        // trim the shareholders array (which drops the last entry)
        delete shareholders[shareholders.length - 1];
        // and zero out the index for addr
        holderIndices[addr] = 0;
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
}
