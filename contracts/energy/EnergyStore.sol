// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";

contract consumerRegistry is Version, Frozen {
  event consumerRegistered(address indexed consumer);
  event consumerDeregistered(address indexed consumer);

  // map address to userID
  mapping(address => uint32) public consumers;

  modifier onlyRegisteredConsumers {
    require(consumers[msg.sender] > 0, "");
    _;
  }

    /// @notice Allow the owner of the address `aconsumer.address()`
    ///         to make transactions on behalf of user id `auserID`.
    ///
    /// @dev Register address aconsumer to belong to userID
    ///      auserID. Addresses can be delisted ("unregistered") by
    ///      setting the userID auserID to zero.
    function registerConsumer(address aconsumer, uint32 auserID)
        external
        payable
        onlyOwner
    {
        if (auserID != 0) {
            emit consumerRegistered(aconsumer);
        } else {
            emit consumerDeregistered(aconsumer);
        }
        consumers[aconsumer] = auserID;
    }
}

/// @title A contract that allows producer addresses to be registered.
///
/// @author Björn Stein, Quantum-Factory GmbH,
///                      https://quantum-factory.de
///
/// @dev License: Attribution-NonCommercial-ShareAlike 2.0 Generic (CC
///              BY-NC-SA 2.0), see
///              https://creativecommons.org/licenses/by-nc-sa/2.0/
contract producerRegistry is Owned {
  event producerRegistered(address indexed producer);
  event producerDeregistered(address indexed producer);

  // map address to bool "is a registered producer"
  mapping(address => bool) public producers;

  modifier onlyRegisteredProducers {
    require(producers[msg.sender], "");
    _;
  }

    /// @notice Allow the owner of address `aproducer.address()` to
    ///         act as a producer (by offering energy).
    function registerProducer(address aproducer)
        external
        payable
        onlyOwner
    {
        emit producerRegistered(aproducer);
        producers[aproducer] = true;
    }

    /// @notice Cease allowing the owner of address
    ///         `aproducer.address()` to act as a producer (by
    ///         offering energy).
    function deregisterProducer(address aproducer)
        external
        payable
        onlyOwner
    {
        emit producerDeregistered(aproducer);
        producers[aproducer] = false;
    }
}

/// @title The Lition Smart Contract, initial development version.
///
/// @author Björn Stein, Quantum-Factory GmbH,
///                      https://quantum-factory.de
///
/// @dev License: Attribution-NonCommercial-ShareAlike 2.0 Generic (CC
///              BY-NC-SA 2.0), see
///              https://creativecommons.org/licenses/by-nc-sa/2.0/
contract EnergyStore is Version, Owned, consumerRegistry, producerRegistry {

    event BidMade(address indexed producer, uint32 indexed day, uint32 indexed price, uint64 energy);
    event BidRevoked(address indexed producer, uint32 indexed day, uint32 indexed price, uint64 energy);
    event Deal(address indexed producer, uint32 indexed day, uint32 price, uint64 energy, uint32 indexed userID);
    event DealRevoked(address indexed producer, uint32 indexed day, uint32 price, uint64 energy, uint32 indexed userID);

    uint64 constant mWh = 1;
    uint64 constant  Wh = 1000 * mWh;
    uint64 constant kWh = 1000 * Wh;
    uint64 constant MWh = 1000 * kWh;
    uint64 constant GWh = 1000 * MWh;
    uint64 constant TWh = 1000 * GWh;
    uint64 constant maxEnergy = 18446 * GWh;

    struct Bid {
        address producer;   // producer's public key
        uint32 day;         // day for which the offer is valid
        uint32 price;       // price vs market price
        uint64 energy;      // energy to sell
        uint64 timestamp;   // timestamp for when the offer was submitted
    }

    struct Ask {
        address producer;
        uint32 day;
        uint32 price;
        uint64 energy;
        uint32 userID;
        uint64 timestamp;
    }

    // bids (for energy: offering energy for sale)
    Bid[] public bids;

    // asks (for energy: demanding energy to buy)
    Ask[] public asks;

    // map (address, day) to index into bids
    mapping(address => mapping(uint32 => uint)) public bidsIndex;

    // map (userid) to index into asks [last take written]
    mapping(uint32 => uint) public asksIndex;

    /// @notice Offer `(aenergy / 1.0e6).toFixed(6)` kWh of energy for
    ///         day `aday` at a price `(aprice / 1.0e3).toFixed(3) + '
    ///         ct/kWh'` above market price for a date given as day
    ///         `aday` whilst asserting that the current date and time
    ///         in nanoseconds since 1970 is `atimestamp`.
    ///
    /// @param aday Day for which the offer is valid.
    /// @param aprice Price surcharge in millicent/kWh above market
    ///        price
    /// @param aenergy Energy to be offered in mWh
    /// @param atimestamp UNIX time (seconds since 1970) in
    ///        nanoseconds
    function offer_energy(uint32 aday, uint32 aprice, uint64 aenergy, uint64 atimestamp)
        external
        payable
        onlyRegisteredProducers
    {
        // require a minimum offer of 1 kWh
        require(aenergy >= kWh, "");

        uint idx = bidsIndex[msg.sender][aday];

        // idx is either 0 or such that bids[idx] has the right producer and day (or both 0 and ...)
        if ((bids.length > idx) && (bids[idx].producer == msg.sender) && (bids[idx].day == aday)) {
            // we will only let newer timestamps affect the stored data
            require(atimestamp > bids[idx].timestamp, "");

            // NOTE: Should we sanity-check timestamps here (ensure that
            //       they are either in the past or not in the too-distant
            //       future compared to the last block's timestamp)?

            emit BidRevoked(bids[idx].producer, bids[idx].day, bids[idx].price, bids[idx].energy);
        }

        // create entry with new index idx for (msg.sender, aday)
        idx = bids.length;
        bidsIndex[msg.sender][aday] = idx;
        bids.push(Bid({
            producer: msg.sender,
            day: aday,
            price: aprice,
            energy: aenergy,
            timestamp: atimestamp
        }));
        emit BidMade(bids[idx].producer, bids[idx].day, bids[idx].price, bids[idx].energy);
    }

    function getBidsCount()
        external
        view
        returns(uint count)
    {
        return bids.length;
    }

    function getBidByProducerAndDay(address producer, uint32 day)
        external
        view
        returns(uint32 price, uint64 energy)
    {
        uint idx = bidsIndex[producer][day];
        require(bids.length > idx, "");
        require(bids[idx].producer == producer, "");
        require(bids[idx].day == day, "");
        return (bids[idx].price, bids[idx].energy);
    }

    /// @notice Buy `(aenergy / 1.0e6).toFixed(6)` kWh of energy on
    ///         behalf of user id `auserID` (possibly de-anonymized by
    ///         randomization) for day `aday` at a surcharge `(aprice
    ///         / 1.0e3).toFixed(3)` ct/kWh from the energy producer
    ///         using the address `aproducer.address()` whilst
    ///         asserting that the current time in seconds since 1970
    ///         is `(atimestamp / 1.0e9)` seconds.
    ///
    /// @param aproducer Address of the producer offering the energy
    ///        to be bought.
    /// @param aday Day for which the offer is valid.
    /// @param aprice Price surcharge in millicent/kWh above market
    ///        price
    /// @param aenergy Energy to be offered in mWh
    /// @param atimestamp UNIX time (seconds since 1970) in
    ///        nanoseconds
    ///
    /// @dev This function is meant to be called by Lition on behalf
    ///      of customers.
    function buy_energy(address aproducer, uint32 aday, uint32 aprice, uint64 aenergy, uint32 auserID, uint64 atimestamp)
        external
        payable
        onlyOwner
    {
        buy_energy_core(aproducer, aday, aprice, aenergy, auserID, atimestamp);
    }

    /// @notice Buy `(aenergy / 1.0e6).toFixed(6)` kWh of energy on
    ///          for day `aday` at a surcharge `(aprice /
    ///          1.0e3).toFixed(3)` ct/kWh from the energy producer
    ///          using the address `aproducer.address()`.
    ///
    /// @param aproducer Address of the producer offering the energy
    ///        to be bought.
    /// @param aday Day for which the offer is valid.
    /// @param aprice Price surcharge in millicent/kWh above market
    ///        price
    /// @param aenergy Energy to be offered in mWh
    ///
    /// @dev This function is meant to be called by a Lition customer
    ///      who has chosen to be registered for this ability and to
    ///      decline anonymization by randomization of user ID.
    function buy_energy(address aproducer, uint32 aday, uint32 aprice, uint64 aenergy)
        external
        payable
        onlyRegisteredConsumers
    {
        buy_energy_core(aproducer, aday, aprice, aenergy, consumers[msg.sender], 0);
    }

    function buy_energy_core(address aproducer, uint32 aday, uint32 aprice, uint64 aenergy, uint32 auserID, uint64 atimestamp)
        internal
    {
        // find offer by producer (aproducer) for day (aday), or zero
        uint idx = bidsIndex[aproducer][aday];

        // if the offer exists...
        if ((bids.length > idx) && (bids[idx].producer == aproducer) && (bids[idx].day == aday)) {
        // ...and has the right price
            require(bids[idx].price == aprice, "");

            // todo: prevent overwriting a later choice...

            // ...then record the customer's choice
            asksIndex[auserID] = asks.length;
            asks.push(Ask({
                producer: aproducer,
                day: aday,
                price: aprice,
                energy: aenergy,
                userID: auserID,
                timestamp: atimestamp
            }));
            emit Deal(aproducer, aday, aprice, aenergy, auserID);
        } else {
            revert("the offer does not exist");
        }
    }

    function getAsksCount()
        external
        view
        returns(uint count)
    {
        return asks.length;
    }

    function getAskByUserID(uint32 userID)
        external
        view
        returns(address producer, uint32 day, uint32 price, uint64 energy)
    {
        uint idx = asksIndex[userID];
        require(asks[idx].userID == userID, "");
        return (asks[idx].producer, asks[idx].day, asks[idx].price, asks[idx].energy);
    }
}