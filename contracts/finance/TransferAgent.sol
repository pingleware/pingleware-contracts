// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../libs/ECVerify.sol";
import "./Shareholder.sol";

import "../interfaces/ITransaction.sol";
import "../interfaces/IAccount.sol";
import "../interfaces/IActiveOffering.sol";
import "../interfaces/IOfferingContract.sol";


contract TransferAgent {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);
    //uint256 constant private negative = type(uint256).max;

    event ExemptOffering(address sender,address offering, uint256 value);
    event OfferingEnabled(address sender,address offering, uint256 timestamp);
    event OfferingDisabled(address sender,address offering, uint256 timestamp);
    event Minted(address addr, uint256 amount);

    event TransferAgentAdded(address owner,address addr);
    event TransferAgentRemoved(address owner,address addr);
    event Transfer(address addr, uint256 amount);
    event TransferFrom(address from,address to,uint256 value);
    event MinterAdded(address addr);

    IAccount Account;
    ITransaction Transaction;
    IActiveOffering ActiveOffering;
    IOfferingContract private Offering;

    struct TransferAgentStorage {
        mapping(address => address[]) transferagents;
        mapping(address => mapping(address => uint256)) _allowances;
        mapping(address => uint256) start_timestamp; // maps offering contract address to startup timestamp
        mapping(address => uint256) minters;
        mapping(address => uint256) parValue;   // maps offering contract address to par value
        address[] contract_address;
        mapping(address => address) owners;
    }

    TransferAgentStorage taStorage;


    constructor(address account_contract,
                address transaction_contract,
                address activeoffering_contract) {
        Account = IAccount(account_contract);
        Transaction = ITransaction(transaction_contract);
        ActiveOffering = IActiveOffering(activeoffering_contract);
    }

    function transferAgentStorage()
        internal
        pure
        returns (TransferAgentStorage storage ds)
    {
        bytes32 position = keccak256("TransferAgent.storage");
        assembly {
            ds.slot := position
        }
    }

    modifier isMinter() {
      require(transferAgentStorage().minters[msg.sender] == 1,"not a minter");
      _;
    }

     // Solving the onlyOwner sppofing: 
     // using web3.eth.sign() to generate a signed hash of the owner address and passing the hash and signature to this method
    modifier onlyTransferAgent(address offering) {
        bool found = false;
        for (uint i = 0; i < transferAgentStorage().transferagents[offering].length; i++) {
            if (transferAgentStorage().transferagents[offering][i] == msg.sender) {
                found = true;
            }
        }
        require(found, "access denied, not valid transfer agent");
        _;
    }

    modifier isTransferAgent(address offering, address addr) {
        bool found = false;
        for (uint i = 0; i < transferAgentStorage().transferagents[offering].length; i++) {
            if (transferAgentStorage().transferagents[offering][i] == msg.sender) {
                found = true;
            }
        }
        require(found, "access denied, not valid transfer agent");
        _;
    }

    function checkTransferAgent(address offering)
        external
        payable
        returns (bool)
    {
        bool found = false;
        for (uint i = 0; i < transferAgentStorage().transferagents[offering].length; i++) {
            if (transferAgentStorage().transferagents[offering][i] == msg.sender) {
                found = true;
            }
        }
        return found;
    }

    function getTransferAgent(address offering)
        external
        view
        returns (address)
    {
        for (uint i = 0; i < transferAgentStorage().transferagents[offering].length; i++) {
            if (transferAgentStorage().transferagents[offering][i] == msg.sender) {
                return transferAgentStorage().transferagents[offering][i];
            }
        }
        return ZERO_ADDRESS;
    }

    //function setMaxUnaccreditInvestors(address offering, uint256 value, uint256 nonce, byte signature)
    //    external
    //    onlyTransferAgent(offering)
   // {
    //    Shareholder.setMaxUnaccreditInvestors(value);
    //}

    // *  Add a verified address, along with an associated verification hash to the contract.
    // *  Upon successful addition of a verified address, the contract must emit
    // *  `VerifiedAddressAdded(addr, hash, msg.sender)`.
    // *  It MUST throw if the supplied address or hash are zero, or if the address has already been supplied.
    // *  @param addr The address of the person represented by the supplied hash.
    // *  @param hash A cryptographic hash of the address holder's verified information.
    function addVerified(address offering, address addr, string memory hash)
        public
        onlyTransferAgent(offering)
    {
        require(addr != ZERO_ADDRESS, "(addVerified) - address is missing");
        require(bytes(hash).length != 0, "(addVerified) - hash is missing");
        require(Shareholder.isVerifiedAddress(addr), "(addVerified) - investor already verified");
        Shareholder.addVerified(addr, hash);
    }

    // *  Remove a verified address, and the associated verification hash. If the address is
    // *  unkblock.timestampn to the contract then this does nothing. If the address is successfully removed, this
    // *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
    // *  It MUST throw if an attempt is made to remove a verifiedAddress that owns Tokens.
    // *  @param addr The verified address to be removed.
    function removeVerified(address offering, address addr)
        external
        onlyTransferAgent(offering)
    {
        require(addr.balance == 0, "account balance is not zero");
        Shareholder.removeVerified(addr);
    }

    // *  Update the hash for a verified address known to the contract.
    // *  Upon successful update of a verified address the contract must emit
    // *  `VerifiedAddressUpdated(addr, oldHash, hash, msg.sender)`.
    // *  If the hash is the same as the value already stored then
    // *  no `VerifiedAddressUpdated` event is to be emitted.
    // *  It MUST throw if the hash is zero, or if the address is unverified.
    // *  @param addr The verified address of the person represented by the supplied hash.
    // *  @param hash A new cryptographic hash of the address holder's updated verified information.
    function updateVerified(address offering, address addr, string memory hash)
        external
        onlyTransferAgent(offering)
    {
        require(bytes(hash).length != 0, "(updateVerified) - hash is zero");
        Shareholder.updateVerified(addr, hash);
    }

    // *  Checks to see if the supplied address was superseded.
    // *  @param addr The address to check.
    // *  @return true if the supplied address was superseded by another address.
    function isSuperseded(address offering, address addr)
        external view
        onlyTransferAgent(offering)
        returns (bool)
    {
        return Shareholder.isSuperseded(addr);
    }

    // *  The number of addresses that own tokens.
    // *  @return the number of unique addresses that own tokens.
    function holderCount(address offering)
        external view
        onlyTransferAgent(offering)
        returns (uint)
    {
        return Shareholder.holderCount();
    }

    // *  By counting the number of token holders using `holderCount`
    // *  you can retrieve the complete list of token holders, one at a time.
    // *  It MUST throw if `index >= holderCount()`.
    // *  @param index The zero-based index of the holder.
    // *  @return the address of the token holder with the given index.
    function holderAt(address offering, uint256 index)
        external view
        onlyTransferAgent(offering)
        returns (address)
    {
        require(index < Shareholder.holderCount(), "holderAt out of bounds");
        return Shareholder.holderAt(index);
    }
    // * Shareholder level:
    // *    1 = non-accredited shareholder
    // *    2 = accredited shareholder
    // *    3 = affiliate shareholder
    function addShareholder(address offering, address addr, Shareholder.InvestorType level)
        external
        onlyTransferAgent(offering)
    {
        Shareholder.addShareholder(offering, addr, level);
    }

    // *  Cancel the original address and reissue the Tokens to the replacement address.
    // *  Access to this function MUST be strictly controlled.
    // *  The `original` address MUST be removed from the set of verified addresses.
    // *  Throw if the `original` address supplied is not a shareholder.
    // *  Throw if the replacement address is not a verified address.
    // *  This function MUST emit the `VerifiedAddressSuperseded` event.
    // *  @param original The address to be superseded. This address MUST NOT be reused.
    // *  @param replacement The address  that supersedes the original. This address MUST be verified.
    function cancelAndReissue(address offering, address original, address replacement)
        external
        onlyTransferAgent(offering)
    {
        require(offering != ZERO_ADDRESS,"invalid offering contract address");
        require(original != ZERO_ADDRESS,"invalid original wallet");
        require(replacement != ZERO_ADDRESS,"invalid replacement wallet");
        require(ActiveOffering.isActive(offering),"offering is not active");
        Shareholder.cancelAndReissue(original, replacement);
    }

    function toggleExemptOffering(address offering, uint256 timestamp, bool _active)
        external
        onlyTransferAgent(offering)
    {
        ActiveOffering.set(offering,_active);

        if (_active) {
            transferAgentStorage().start_timestamp[offering] = timestamp;
            emit OfferingEnabled(msg.sender, offering, timestamp);
        } else {
            emit OfferingDisabled(msg.sender, offering, timestamp);
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
      external
      view
      returns (uint256)
    {
        return transferAgentStorage()._allowances[_owner][spender];
    }

    function addMinter(address offering, address addr)
      external
      onlyTransferAgent(offering)
    {
      require(addr != ZERO_ADDRESS, "missing minter address");
      transferAgentStorage().minters[addr] = 1;
      emit MinterAdded(addr);
    }

    function addTransferAgent(address offering, address addr)
        external
    {
        require(msg.sender != ZERO_ADDRESS, "missing owner address");
        require(addr != ZERO_ADDRESS, "missing transfer agent address");
        Offering = IOfferingContract(offering);
        require(msg.sender != Offering.getOwner(),"unauthorized access");
        transferAgentStorage().transferagents[offering].push(addr);
        transferAgentStorage().owners[offering] = msg.sender;
        emit TransferAgentAdded(msg.sender, addr);
    }

    function removeTransferAgent(address offering, address addr)
        external
    {
        require(msg.sender != ZERO_ADDRESS, "missing owner address");
        require(addr == ZERO_ADDRESS,"missing transfer agent address");
        Offering = IOfferingContract(offering);
        require(msg.sender != Offering.getOwner(),"unauthorized access");
        for (uint i = 0; i < transferAgentStorage().transferagents[offering].length; i++) {
            if (transferAgentStorage().transferagents[offering][i] == addr) {
                delete transferAgentStorage().transferagents[offering][i];
            }
        }
        emit TransferAgentRemoved(msg.sender, addr);
    }

    // *  Tests that the supplied address is known to the contract.
    // *  @param addr The address to test.
    // *  @return true if the address is known to the contract.
    function isVerified(address addr)
        external
        view
        returns (bool)
    {
        return Shareholder.isVerifiedAddress(addr);
    }


    // *  Gets the most recent address, given a superseded one.
    // *  Addresses may be superseded multiple times, so this function needs to
    // *  follow the chain of addresses until it reaches the final, verified address.
    // *  @param addr The superseded address.
    // *  @return the verified address that ultimately holds the share.
    function getCurrentFor(address offering, address addr)
        external
        onlyTransferAgent(offering)
        returns (address)
    {
        return findCurrentFor(addr);
    }

    // *  Recursively find the most recent address given a superseded one.
    // *  @param addr The superseded address.
    // *  @return the verified address that ultimately holds the share.
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
        external
        onlyTransferAgent(_contract)
    {
        transferAgentStorage().contract_address.push(_contract);
        transferAgentStorage().parValue[_contract] = value;
    }

    // * As each token is minted it is added to the shareholders array.
    // * @param _to The address that will receive the minted tokens.
    // * @param _amount The amount of tokens to mint.
    // * @return A boolean that indicates if the operation was successful.
    function mint(address offering, address _to, uint256 _amount, uint256 _epoch, uint256 _initial_supply)
        external
        onlyTransferAgent(offering)
        isMinter
        returns (bool)
    {
        require(offering != ZERO_ADDRESS,"invalid offering contract");
        require(ActiveOffering.isActive(offering),"offering is not active");
        // if the address does not already own share then
        // add the address to the shareholders array and record the index.
        require(_epoch >= block.timestamp, "time spoofing error");
        Shareholder.updateShareholders(_to);
        uint256 _shares = _amount / transferAgentStorage().parValue[offering];
        Transaction.addTransaction(_to, _shares, _amount, _epoch);
        Account.add(offering, _shares);

        return _mint(_to, _amount, _initial_supply);
    }

    // *  The `transfer` function MUST NOT allow transfers to addresses that
    // *  have not been verified and added to the contract.
    // *  If the `to` address is not currently a shareholder then it MUST become one.
    // *  If the transfer will reduce `msg.sender`'s balance to 0 then that address
    // *  MUST be removed from the list of shareholders.
    function transfer(address offering, address to, uint256 value, uint256 epoch)
        external
        returns (bool)
    {
        require(offering != ZERO_ADDRESS,"invalid offering contract");
        require(ActiveOffering.isActive(offering),"offering is not active");
        require(Transaction.isHoldingPeriodOver(to),"holding period has not expired");
        Shareholder.updateShareholders(to);
        Shareholder.pruneShareholders(msg.sender, value);
        uint256 _shares = value / transferAgentStorage().parValue[offering];
        Transaction.addTransaction(to, _shares, value, epoch);
        Transaction.addTransaction(msg.sender, _shares, value, epoch);

        return _transfer(to, value);
    }

    // *  The `transferFrom` function MUST NOT allow transfers to addresses that
    // *  have not been verified and added to the contract.
    // *  If the `to` address is not currently a shareholder then it MUST become one.
    // *  If the transfer will reduce `from`'s balance to 0 then that address
    // *  MUST be removed from the list of shareholders.
    function transferFrom(address offering, address from, address to, uint256 value, uint256 epoch)
        external
        returns (bool)
    {
        require(offering != ZERO_ADDRESS,"invalid offering contract");
        require(from != ZERO_ADDRESS,"invalid wallet");
        require(to != ZERO_ADDRESS,"invalid wallet");
        require(ActiveOffering.isActive(offering),"offering is not active");
        require(Transaction.isHoldingPeriodOver(to),"holding period has not expired");
        Shareholder.updateShareholders(to);
        Shareholder.pruneShareholders(from, value);
        uint256 _shares = value / transferAgentStorage().parValue[offering];
        Transaction.addTransaction(to, _shares, value, epoch);
        Transaction.addTransaction(from, _shares, value, epoch);

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