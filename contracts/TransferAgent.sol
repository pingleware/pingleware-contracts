// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";
import "./Transaction.sol";
import "./ecverify.sol";
import "./ActiveOffering.sol";
import "./Shareholder.sol";
import "./Account.sol";
import "./Transaction.sol";

abstract contract TransferAgent is Owned
{
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);
    uint256 constant private negative = type(uint256).max;

    mapping(address => bool) private transferagents;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private start_timestamp;

    event ExemptOffering(address indexed from,string status, uint256 value);
    event Minted(address addr, uint256 amount);

    event TransferAgentAdded(address owner,address addr);
    event TransferAgentRemoved(address owner,address addr);
    event Transfer(address addr, uint256 amount);
    event TransferFrom(address from,address to,uint256 value);
    event MinterAdded(address addr);

    mapping(address => uint256) private minters;

    uint256 private parValue = 0;

    address private contract_address;


    modifier isMinter() {
      require(minters[msg.sender] == 1,"not a minter");
      _;
    }

    modifier onlyTransferAgent() {
        require(transferagents[msg.sender] == true, "access denied for the transfer agent");
        _;
    }


    modifier isTransferAgent(address addr) {
        require(transferagents[addr] == true, "user denied access as a transfer agent");
        _;
    }

    function setMaxUnaccreditInvestors(uint256 value)
        public
        onlyTransferAgent
    {
        Shareholder.setMaxUnaccreditInvestors(value);
    }


    /**
     *  Add a verified address, along with an associated verification hash to the contract.
     *  Upon successful addition of a verified address, the contract must emit
     *  `VerifiedAddressAdded(addr, hash, msg.sender)`.
     *  It MUST throw if the supplied address or hash are zero, or if the address has already been supplied.
     *  @param addr The address of the person represented by the supplied hash.
     *  @param hash A cryptographic hash of the address holder's verified information.
     */
    function addVerified(address addr, string memory hash)
        public
        onlyTransferAgent
    {
        require(addr != ZERO_ADDRESS, "(addVerified) - address is missing");
        require(bytes(hash).length != 0, "(addVerified) - hash is missing");
        require(Shareholder.isVerifiedAddress(addr), "(addVerified) - investor already verified");
        Shareholder.addVerified(addr, hash);
    }

    /**
     *  Remove a verified address, and the associated verification hash. If the address is
     *  unkblock.timestampn to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  It MUST throw if an attempt is made to remove a verifiedAddress that owns Tokens.
     *  @param addr The verified address to be removed.
     */
    function removeVerified(address addr)
        public
        onlyTransferAgent
    {
        require(addr.balance == 0, "account balance is not zero");
        Shareholder.removeVerified(addr);
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
    function updateVerified(address addr, string memory hash)
        public
        onlyTransferAgent
    {
        require(bytes(hash).length != 0, "(updateVerified) - hash is zero");
        Shareholder.updateVerified(addr, hash);
    }

    /**
     *  Checks to see if the supplied address was superseded.
     *  @param addr The address to check.
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr)
        public
        payable
        onlyTransferAgent
        returns (bool)
    {
        return Shareholder.isSuperseded(addr);
    }

    /**
     *  The number of addresses that own tokens.
     *  @return the number of unique addresses that own tokens.
     */
    function holderCount()
        public
        payable
        onlyTransferAgent
        returns (uint)
    {
        return Shareholder.holderCount();
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
        payable
        onlyTransferAgent
        returns (address)
    {
        require(index < Shareholder.holderCount(), "holderAt out of bounds");
        return Shareholder.holderAt(index);
    }
    /**
     * Shareholder level:
     *    1 = non-accredited shareholder
     *    2 = accredited shareholder
     *    3 = affiliate shareholder
     * 
     */
    function addShareholder(address addr, uint level)
        public
        payable
        onlyTransferAgent
    {
        Shareholder.addShareholder(addr, level);
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
        onlyTransferAgent
    {
        require(ActiveOffering.isActive(),"offering is not active");
        Shareholder.cancelAndReissue(original, replacement);
    }



    function toggleExemptOffering(string memory name, uint256 timestamp, bool _active, uint256 _initial_supply)
        public
        onlyTransferAgent
    {
        start_timestamp = timestamp;
        ActiveOffering.set(_active);

        if (_active) {
            emit ExemptOffering(msg.sender, string(abi.encodePacked(name, " has started")), timestamp);
            if (start_timestamp != 0) {
                _mint(msg.sender, _initial_supply, _initial_supply);
            }
        } else {
            emit ExemptOffering(msg.sender, string(abi.encodePacked(name, " has stopped")), timestamp);
        }
    }

    function _mint(address addr, uint256 amount, uint256 _initial_supply)
      internal
      returns (bool)
    {
      require(amount <= _initial_supply, "exceeds total supply");
      emit Minted(addr, amount);
      return true;
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
      onlyTransferAgent
    {
      require(addr != ZERO_ADDRESS, "missing minter address");
      minters[addr] = 1;
      emit MinterAdded(addr);
    }

    function addTransferAgent(address addr, bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
    {
        require(addr != ZERO_ADDRESS, "missing transfer agent address");
        transferagents[addr] = true;
        emit TransferAgentAdded(getOwner(), addr);
    }

    function removeTransferAgent(address addr,  bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
    {
        require(addr == ZERO_ADDRESS,"missing transfer agent address");
        transferagents[addr] = false;
        emit TransferAgentRemoved(getOwner(), addr);
    }




    /**
     *  Tests that the supplied address is known to the contract.
     *  @param addr The address to test.
     *  @return true if the address is known to the contract.
     */
    function isVerified(address addr)
        public
        payable
        returns (bool)
    {
        return Shareholder.isVerifiedAddress(addr);
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
        payable
        onlyTransferAgent
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
        returns (address)
    {
        if (Shareholder.isCancelled(addr)) {
            return addr;
        }
        return findCurrentFor(addr);
    }

    function setParValue(address _contract, uint256 value)
        public
        payable
        onlyTransferAgent
    {
        contract_address = _contract;
        parValue = value;
    }

    /**
     * As each token is minted it is added to the shareholders array.
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount, uint256 _epoch, uint256 _initial_supply)
        public
        onlyTransferAgent
        isMinter
        returns (bool)
    {
        require(ActiveOffering.isActive(),"offering is not active");
        // if the address does not already own share then
        // add the address to the shareholders array and record the index.
        require(_epoch >= block.timestamp, "time spoofing error");
        Shareholder.updateShareholders(_to);
        uint256 _shares = _amount / parValue;
        Transaction.addTransaction(_to, _shares, _amount, _epoch);
        Account.add(contract_address, _amount);

        return _mint(_to, _amount, _initial_supply);
    }

    /**
     *  The `transfer` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `msg.sender`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transfer(address to, uint256 value, uint256 epoch)
        public
        returns (bool)
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Transaction.isHoldingPeriodOver(to),"holding period has not expired");
        Shareholder.updateShareholders(to);
        Shareholder.pruneShareholders(msg.sender, value);
        uint256 _shares = value / parValue;
        Transaction.addTransaction(to, _shares, value, epoch);
        Transaction.addTransaction(msg.sender, _shares, negative * value, epoch);

        return _transfer(to, value);
    }

    /**
     *  The `transferFrom` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `from`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transferFrom(address from, address to, uint256 value, uint256 epoch)
        public
        returns (bool)
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Transaction.isHoldingPeriodOver(to),"holding period has not expired");
        Shareholder.updateShareholders(to);
        Shareholder.pruneShareholders(from, value);
        uint256 _shares = value / parValue;
        Transaction.addTransaction(to, _shares, value, epoch);
        Transaction.addTransaction(from, _shares, negative * value, epoch);

        return _transferFrom(from, to, value);
    }

    // Internal

    function _transfer(address addr, uint256 amount)
      internal
      returns (bool)
    {
        Account.setBalance(addr, amount);
        emit Transfer(addr, amount);
        return true;
    }

    function _transferFrom(address from,address to,uint256 value)
      internal
      returns (bool)
    {
        Account.isSufficientBalance(from, value);
        Account.transfer(from, to, value);
        emit TransferFrom(from, to, value);
        return true;
    }
}