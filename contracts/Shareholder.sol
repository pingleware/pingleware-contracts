// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


library Shareholder {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);
    uint256 constant private negative = type(uint256).max;

    struct ShareholderStorage {
        mapping(address => address) cancellations;
        mapping(address => uint256) holderIndices;
        mapping(address => string)  verified;
        address[] _verified;
        address[] shareholders;
        address[] shareholders_nonacredited;
        address[] shareholders_affiliate;
        uint256 maxNonaccredited;
    }

    function shareholderStorage() internal pure returns (ShareholderStorage storage ds)
    {
        bytes32 position = keccak256("shareholder.storage");
        assembly { ds.slot := position }
    }


    event VerifiedAddressSuperseded(address addr1,address addr2,address addr3);
    event VerifiedAddressUpdated(address addr, string oldhash, string hash, address sender);
    event VerifiedAddressRemoved(address addr, address sender);
    event VerifiedAddressAdded(address addr, string hash, address sender);

    function isShareholder(address addr)
        internal
        view
        returns (bool)
    {
        return (shareholderStorage().holderIndices[addr] != 0);
    }

    function isNotShareholder(address addr)
        internal
        view
        returns (bool)
    {
        return (shareholderStorage().holderIndices[addr] == 0);
    }

    function isVerifiedAddress(address addr)
        internal
        view
        returns (bool)
    {
        return (bytes(shareholderStorage().verified[addr]).length > 0);
    }

    function isNotCancelled(address addr)
        internal
        view
        returns (bool)
    {
        return (shareholderStorage().cancellations[addr] == ZERO_ADDRESS);
    }

    function isCancelled(address addr)
        internal
        view
        returns (bool)
    {
        if (shareholderStorage().cancellations[addr] == ZERO_ADDRESS) {
            return true;
        }
        return false;
    }

    function setMaxUnaccreditInvestors(uint256 value)
        internal
    {
        shareholderStorage().maxNonaccredited = value;
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
        internal
    {
        require(isNotCancelled(addr), "(addVerified) - investor is already cancelled");
        require(bytes(shareholderStorage().verified[addr]).length ==  0, "(addVerified) - investor already verified");
        shareholderStorage().verified[addr] = hash;
        shareholderStorage()._verified.push(addr);
        emit VerifiedAddressAdded(addr, hash, msg.sender);
    }

    /**
     *  Remove a verified address, and the associated verification hash. If the address is
     *  unkblock.timestampn to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  It MUST throw if an attempt is made to remove a verifiedAddress that owns Tokens.
     *  @param addr The verified address to be removed.
     */
    function removeVerified(address addr)
        internal
    {
        if (bytes(shareholderStorage().verified[addr]).length != 0) {
            delete shareholderStorage().verified[addr];
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
    function updateVerified(address addr, string memory hash)
        internal
    {
        require(isVerifiedAddress(addr), "(updateVerified) - not a verified investor");
        require(bytes(hash).length != 0, "(updateVerified) - hash is zero");
        string memory oldHash = shareholderStorage().verified[addr];
        if (keccak256(abi.encodePacked((oldHash))) != keccak256(abi.encodePacked((hash)))) {
            shareholderStorage().verified[addr] = hash;
            emit VerifiedAddressUpdated(addr, oldHash, hash, msg.sender);
        }
    }

    /**
     *  Checks to see if the supplied address was superseded.
     *  @param addr The address to check.
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr)
        internal
        view
        returns (bool)
    {
        return shareholderStorage().cancellations[addr] != ZERO_ADDRESS;
    }

    /**
     *  Checks to see if the supplied address is a share holder.
     *  @param addr The address to check.
     *  @return true if the supplied address owns a token.
     */
    function isHolder(address addr)
        internal
        view
        returns (bool)
    {
        return shareholderStorage().holderIndices[addr] != 0;
    }

    /**
     *  Checks that the supplied hash is associated with the given address.
     *  @param addr The address to test.
     *  @param hash The hash to test.
     *  @return true if the hash matches the one supplied with the address in `addVerified`, or `updateVerified`.
     */
    function hasHash(address addr, bytes32 hash)
        internal
        view
        returns (bool)
    {
        if (addr == ZERO_ADDRESS) {
            return false;
        }
        return  keccak256(abi.encodePacked((shareholderStorage().verified[addr]))) == keccak256(abi.encodePacked((hash)));
    }

    /**
     *  The number of addresses that own tokens.
     *  @return the number of unique addresses that own tokens.
     */
    function holderCount()
        internal
        view
        returns (uint)
    {
        return shareholderStorage().shareholders.length;
    }

    /**
     *  By counting the number of token holders using `holderCount`
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if `index >= holderCount()`.
     *  @param index The zero-based index of the holder.
     *  @return the address of the token holder with the given index.
     */
    function holderAt(uint256 index)
        internal
        view
        returns (address)
    {
        require(index < shareholderStorage().shareholders.length, "holderAt out of bounds");
        return shareholderStorage().shareholders[index];
    }
    /**
     * Shareholder level:
     *    1 = non-accredited shareholder
     *    2 = accredited shareholder
     *    3 = affiliate shareholder
     * 
     */
    function addShareholder(address addr, uint level)
        internal
    {
        if (shareholderStorage().holderIndices[addr] == 0) {
            if (level == 1) {
                require(shareholderStorage().shareholders_nonacredited.length < shareholderStorage().maxNonaccredited, "will exceed the maximum number of non-accredited investors");
                shareholderStorage().shareholders_nonacredited.push(addr);
                shareholderStorage().holderIndices[addr] = 1;
            } else if (level == 2) {
              shareholderStorage().shareholders.push(addr);
              shareholderStorage().holderIndices[addr] = 1;
            } else if (level == 3) {
              shareholderStorage().shareholders_affiliate.push(addr);
              shareholderStorage().holderIndices[addr] = 1;
            }
        }
    }

    /**
     *  If the address is not in the `shareholders` array then push it
     *  and update the `holderIndices` mapping.
     *  @param addr The address to add as a shareholder if it's not already.
     */
    function updateShareholders(address addr)
        internal
    {
        require(isVerifiedAddress(addr), "investor is not verified");
        if (shareholderStorage().holderIndices[addr] == 0) {
          shareholderStorage().shareholders.push(addr);
          shareholderStorage().holderIndices[addr] = 1;
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
        uint256 holderIndex = shareholderStorage().holderIndices[addr] - 1;
        uint256 lastIndex = shareholderStorage().shareholders.length - 1;
        address lastHolder = shareholderStorage().shareholders[lastIndex];
        // overwrite the addr's slot with the last shareholder
        shareholderStorage().shareholders[holderIndex] = lastHolder;
        // also copy over the index (thanks @mohoff for spotting this)
        // ref https://github.com/davesag/ERC884-reference-implementation/issues/20
        shareholderStorage().holderIndices[lastHolder] = shareholderStorage().holderIndices[addr];
        // trim the shareholders array (which drops the last entry)
        delete shareholderStorage().shareholders[shareholderStorage().shareholders.length - 1];
        // and zero out the index for addr
        shareholderStorage().holderIndices[addr] = 0;
    }

    /**
     *  Cancel the original address and reissue the Tokens to the replacement address.
     *  Access to this function MUST be strictly controlled.
     *  The `original` address MUST be removed from the set of verified addresses.
     *  Throw if the `original` address supplied is not a 
     *  Throw if the replacement address is not a verified address.
     *  This function MUST emit the `VerifiedAddressSuperseded` event.
     *  @param original The address to be superseded. This address MUST NOT be reused.
     *  @param replacement The address  that supersedes the original. This address MUST be verified.
     */
    function cancelAndReissue(address original, address replacement)
       internal
       returns (address, address)
    {
        require(isShareholder(original), "(cancelandReissue) - original investor is not a shareholder");
        require(isNotShareholder(replacement), "(cancelandReissue) - replacement investor is already a shareholder, requires a new wallet");
        require(isVerifiedAddress(replacement), "(cancelandReissue) - replacement investor is not a verified investor");
        // replace the original address in the shareholders array
        // and update all the associated mappings
        shareholderStorage().verified[original] = "";
        shareholderStorage().cancellations[original] = replacement;
        uint256 holderIndex = shareholderStorage().holderIndices[original] - 1;
        shareholderStorage().shareholders[holderIndex] = replacement;
        shareholderStorage().holderIndices[replacement] = shareholderStorage().holderIndices[original];
        shareholderStorage().holderIndices[original] = 0;
        emit VerifiedAddressSuperseded(original, replacement, msg.sender);
        //transferBalances(original, replacement);
        return (original, replacement);
    }
}