// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";


contract RideshareTrade is Version, Frozen {
    uint256 public s = 1;
    uint256 public c;
    uint256 public t=1;
    mapping (address => uint) balances;

    address payable agent;  // agent owns smart contract
    address payable tnc;    // transportation network company
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

    struct DriverData {
        address payable driver;
        bytes   id;
        string  name;
        string  contact;
    }

    struct TripData {
        address payable driver;
        bytes32 tripno;
        string  pickup;
        string  dropoff;
        uint256 miles;
        uint256 booking_time;
        uint256 begin_time;
        uint256 finish_time;
    }

    address[] public d1;
    mapping(address => DriverData) public drivers;

    mapping (bytes32 => TripData) t1;
    TripData[] public trips;

    event Bought(bytes32 trans, address payable buyer);
    event Confirmed(bytes32 trans, address payable buyer);
    event Cancelled(bytes32 trans, address payable buyer);
    event TripAdded(bytes32 trans, uint index);

   constructor() {
        agent = payable(msg.sender);
        penality = 100;
    }

    modifier valid(uint _starting, uint _timestamp) {
        require(_starting > _timestamp, "");
        _;
    }

    modifier identity() {
        require(msg.sender == network, "");
        _;
    }

    function fundaddr(address addr) public{
        balances[addr] = 2000;
    }

    function sendCoin(address receiver, uint amount, address sender)
        public
        returns(bool sufficient)
    {
        if (balances[sender] < amount) {
            return false;
        }

        balances[sender] -= amount;
        balances[receiver] += amount;

        return true;
    }

    function getBalance(address addr)
        public
        view
        returns(uint)
    {
        return balances[addr];
    }

    function addDriver(bytes memory id,string memory name,string memory contact)
        public
        returns (uint256)
    {
        require(msg.sender != address(0),"zero address not permitted");
        DriverData memory _driver = DriverData(payable(msg.sender),id,name,contact);
        drivers[msg.sender] = _driver;
        d1.push(msg.sender);
        return (d1.length - 1);
    }

    /**
     * no = trasn used in the buy function
     * The rider/customer buys a trip via the buy routine, and after the transaction is confirmed and paid,
     * then a new trip is added. The offchain process will poll the unassigned trips and assign a matching driver
     */
    function addTrip(bytes32 no,string memory pickup,string memory dropoff,uint miles,uint book, uint256 begintime, uint256 endtime)
        public
        returns (uint)
    {
        // TODO: better authentication so the msg.sender cannot be spoofed?
        require(offers[no].buyer == msg.sender,"Buyer does not match");
        // initially set driver as zero address for matching to assign the driver?
        TripData memory _trip = TripData(payable(address(0)),no,pickup,dropoff,miles,book,begintime,endtime);
        trips.push(_trip);
        t1[no] = _trip;
        emit TripAdded(no,trips.length - 1);
        return (trips.length - 1);
    }

    function getDriver()
        public
        view
        returns (address,bytes memory,string memory,string memory)
    {
        require(msg.sender != address(0),"zero address not permitted");
        return (msg.sender,drivers[msg.sender].id,drivers[msg.sender].name,drivers[msg.sender].contact);
    }

    function getTrip(uint i)
        public
        view
        returns (address,bytes32)
    {
        return (trips[i].driver,
                trips[i].tripno);
    }

    function getTripPickupLocation(uint i)
        public
        view
        returns (string memory)
    {
        return trips[i].pickup;
    }

    function getTripDropoffLocation(uint i)
        public
        view
        returns (string memory)
    {
        return trips[i].dropoff;
    }

    function getTripMiles(uint i)
        public
        view
        returns (uint256)
    {
        return trips[i].miles;
    }

    function getTripTravelInfo(uint i)
        public
        view
        returns (string memory,string memory, uint256)
    {
        return (trips[i].pickup,trips[i].dropoff,trips[i].miles);
    }

    function getTripTravelTimes(uint i)
        public
        view
        returns (uint256,uint256,uint256)
    {
        return (trips[i].booking_time,trips[i].begin_time,trips[i].finish_time);
    }

    function addNetwork(address payable _network)
        public
        payable
    {
        network = _network;
    }

    function assignTrip(uint tripid,address payable driver)
        public
        okOwner
    {
        require(trips[tripid].driver == address(0),"trip is already assigned to a driver");
        trips[tripid].driver = payable(driver);
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
            emit Bought(_trans, payable(msg.sender));
        }
    }

    function cancel(bytes32 _trans, uint _timestamp)
        public
        payable
    {
        if (offers[_trans].buyer == msg.sender) {
            // buyer can cancel is starting time for rideshare transfer hasn't yet started
            // must pay penality
            if (offers[_trans].starting > _timestamp) {
                offers[_trans].buyer = payable(address(0x0));
                // person must pay penality
                if (t1[_trans].driver != address(0)) {
                    // if trip has beend assigned to a driver, driver gets half the penalty
                    payable(msg.sender).transfer(penality / 2);
                    t1[_trans].driver.transfer(penality / 2);
                    payable(msg.sender).transfer(penality / 2);
                    agent.transfer(penality / 2);
                } else {
                    // if the trip is not assigned to a driver, the agent gets all of the penalty
                    payable(msg.sender).transfer(penality);
                    agent.transfer(penality);
                }
                emit Cancelled(_trans,payable(msg.sender));
            }
        }
    }

    // network confrims rideshare transfer is possible, if not offer is invalid
    function confirm(bytes32 _trans, uint _timestamp)
        public
        identity
        payable
    {
        if (offers[_trans].starting > _timestamp) {
            offers[_trans].confirmed = true;
            emit Confirmed(_trans, offers[_trans].buyer);
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