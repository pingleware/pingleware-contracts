// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * The Hertz-Dollar rental car false arrests fiasco make implementing rental car contracts in the blockchain
 * safer for both company and consumer. Read more athttps://6abc.com/hertz-rental-car-lawsuits-arrests-wrongful-cars/12143532/.
 */


contract RentalCar {
    address private owner;
    struct Vehicle {
        string vin;
        string tag;
        string state;
        string make;
        string model;
        uint256 year;
    }

    struct Rental {
        Vehicle vehicle;
        uint256 start;
        uint256 expiry;
        uint256 validation;
    }

    mapping(address => bool) private _consumers;
    mapping(address => Rental) private _rentals;
    mapping(uint256 => Vehicle) private _vehicles;

    event VehicleAdded(uint timestamp, Vehicle vehicle);
    event ConsumerAdded(address consumer,uint256 timestamp);
    event RentalAdded(address consumer, Vehicle vehicle, uint256 timestamp);
    event RentalExtended(address consumer, Vehicle vehicle, uint256 extendedDate, uint256 timestamp);
    event RentalReturned(address consumer, Vehicle vehicle, uint256 timestamp);

    constructor() {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner,"unauthorized access");
        _;
    }

    modifier vehicleXist(string memory vin) {
        _;
    }

    modifier isConsumer() {
        _;
    }

    modifier notExpired() {
        require(_rentals[msg.sender].expiry > block.timestamp,"rental has expired! you could be criminally liable for grand theft auto?");
        _;
    }

    modifier isValidRental(uint256 ts) {
        require(_rentals[msg.sender].start == ts,"not a valid rental");
        _;
    }

    modifier hasValidation(uint256 validation) {
        require(_rentals[msg.sender].validation == validation,"validation is not correct");
        _;
    }

    function getVehicles() public view isOwner returns(uint256[] memory) {
        uint256[] memory list;
        // TODO: get list of timestamps from _vehicles mappings?
        return list;
    }

    function addVehicle(uint256 timestamp,
                        string memory vin,
                        string memory tag,
                        string memory state,
                        string memory make,
                        string memory model,
                        uint256 year)
        public
        payable
        isOwner
        returns(uint256)
    {
        Vehicle memory vehicle = Vehicle(vin,tag,state,make,model,year);
        _vehicles[timestamp] = vehicle;
        emit VehicleAdded(timestamp,vehicle);
        return timestamp;
    }

    function addConsumer(address consumer,uint256 timestamp)
        public
        payable
        isOwner
        returns (uint256)
    {
        _consumers[consumer] = true;
        emit ConsumerAdded(consumer,timestamp);
        return timestamp;
    }

    function newRental(uint256 vehicleTimestamp,address consumer,uint256 timestamp,uint256 expiry)
        public
        payable
        isOwner
        returns (uint256)
    {
        Vehicle memory vehicle = _vehicles[vehicleTimestamp];
        _rentals[consumer] = Rental(vehicle,timestamp,expiry,0);
        emit RentalAdded(consumer,vehicle,timestamp);
        return timestamp;
    }

    function addValidation(uint256 vehicleTimestamp,address consumer,uint validation)
        public
        payable
        isOwner
        isValidRental(vehicleTimestamp)
    {
        _rentals[consumer].validation = validation;
    }

    function extendRental(uint256 rentalTimestamp,uint256 expiry)
        public
        payable
        isConsumer
        isValidRental(rentalTimestamp)
        notExpired
        returns (uint256)
    {
        _rentals[msg.sender].expiry = expiry;
        emit RentalExtended(msg.sender,_rentals[msg.sender].vehicle,expiry,rentalTimestamp);
        return expiry;
    }

    /**
     * The consumer reports when they returned the vehicle but requires the rental company to provide
     * a validation timestamp to the consumer inorder for the return to be accepted. This prevents
     * a consumer from reporting a vehicle is returned witout a company verifying the vehicle has been returned.
     */
    function returnRental(uint256 rentalTimestamp,uint256 timestamp,uint256 validation)
        public
        payable
        isConsumer
        isValidRental(rentalTimestamp)
        notExpired
        hasValidation(validation)
        returns (uint256)
    {
        Rental memory rental = _rentals[msg.sender]; // make local copy
        delete _rentals[msg.sender]; // delete from gloobal ammping
        emit RentalReturned(msg.sender,rental.vehicle,timestamp); //notify of rental returned
        return timestamp;
    }
}