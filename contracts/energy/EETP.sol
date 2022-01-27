// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * From: https://github.com/Yassin-MT/EETP
 *
 * An Ethereum-Based Energy Trading Protocol
 * This is an P2P Energy Trading Protocol built on Ethereum's Smart Contract technology. On this platform, any entity can buy or sell electricity,
 * there is no limit on the number of participants, and there are no intermediaries (e.g. banks, traders and energy retailers).
 * The proposed solution uses off-chain and on-chain processing (and storage) with the objective to perform as much processing off-chain as possible,
 * without compromising the security of the solution.
 *
 * Using Ethereum's smart contract technology, the solution realizes a secure, decentralized, trustworthy, and low-cost energy trading in next generation smart grids.
 *
 * The Actors
 * There are four actors in the proposed protocol.
 *      a) the producer: an entity that has a block of electricity to sell sometime in the future;
 *      b) the consumer: an entity that wants to buy electricity;
 *      c) the energy agent: an entity that maintains an energy inventory, provided by producers, and matches it to consumer requests; and
 *     (d) the distribution network: an electric power network that transports electricity between two end points.
 */
contract EETP {
    address payable agent; // energy agent owns smart contract
    address payable network; // distribution network

    uint penality; // penality for cancelling

    struct offer {
        address payable buyer;
        uint starting;
        uint duration;
        bool confirmed;
    }

    // hash of energy offer (processed by energy agent) mapped to offer
    mapping (bytes32 => offer) public offers;

    event bought(bytes32 trans, address payable buyer);
    event confirmed(bytes32 trans, address payable buyer);

    constructor() {
        agent = payable(msg.sender);
        penality = 100;
    }

    modifier valid(uint _starting, uint _timestamp) {
        require(_starting > _timestamp, "");
        _;
    }

    function addNetwork(address payable _network)
        public
        payable
    {
        network = _network;
    }

    function buy(bytes32 _trans, uint _starting, uint _duration, uint _timestamp)
        public
        valid(_starting,_timestamp)
        payable
    {
        offer memory anOffer;

        // offer must be available (ie hasn't been bought yet)
        if (offers[_trans].buyer == address(0x0)) {
            anOffer.buyer = payable(msg.sender);
            anOffer.starting = _starting;
            anOffer.duration = _duration;

            offers[_trans] = anOffer;
            emit bought(_trans, payable(msg.sender));
        }
    }

    function cancel(bytes32 _trans, uint _timestamp)
        public
        payable
    {
        if (offers[_trans].buyer == msg.sender) {
        // buyer can cancel is starting time for energy transfer hasn't yet started
        // must pay penality
        if (offers[_trans].starting > _timestamp) {
            offers[_trans].buyer = payable(address(0x0));
            // person must pay penality
            payable(msg.sender).transfer(penality);
            agent.transfer(penality);
        }
        }
    }

    modifier identity() {
        require(msg.sender == network, "");
        _;
    }

    // network confrims energy transfer is possible, if not offer is invalid
    function confirm(bytes32 _trans, uint _timestamp)
        public
        identity
        payable
    {
        if (offers[_trans].starting > _timestamp) {
            offers[_trans].confirmed = true;
            emit confirmed(_trans, offers[_trans].buyer);
        }
    }

    // buyer pays once offer has been confirmed
    function pay(bytes32 _trans)
        public
        payable
    {
        if (offers[_trans].buyer == msg.sender && offers[_trans].confirmed == true) {
            // payment
            payable(msg.sender).transfer(msg.value);
            agent.transfer(msg.value);
        }
    }
}