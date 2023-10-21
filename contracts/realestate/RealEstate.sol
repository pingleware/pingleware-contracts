// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

// current status: 2 different states.
contract RealEstate is Version, Owned {
    bool public active;
    enum STATUS {
        OFFMARKET,
        LISTED,
        PENDING,
        SOLD
    }

    enum PROPERTY_TYPE {
        SINGLEFAMILY,
        DUPLEX,
        TRIPLEX,
        QUADPLEX,
        MULTIFAMILY,
        CONDO,
        COOP,
        MOBILEHOME,
        LAND
    }

    constructor ()
    {
        active = true;
    }

    //counter to count property & increment Id.
    uint256 public propertyCount;
    address public owner;
    uint[] private myArray;

    // A lien should be a separate contract?
    struct Lien {
        uint position;
        address lienholder;
        uint256 origination_date;
        uint256 terms;
        uint256 amount;
    }

    struct NewProperty {
        uint propertyId;
        uint cost;
        string location;
        STATUS status;
        PROPERTY_TYPE property_type;
        address ownerAddr;
    }

    struct Sale {
        address property;
        uint256 sale_date;
        address seller;
        address buyer;
        uint256 amount;
    }

    struct Taxes {
        address taxcollector;
        address property;
        uint256 amount;
    }

    struct TaxRecord {
        Taxes tax;
        address payer;
        uint256 duedate;
        uint256 date_paid;
        uint256 amount;
    }

    struct TaxDeliquency {
        Taxes tax;
        uint256 date;
        uint256 amount;
        bool    certificate_issued;
        bool    taxdeed_issued;
    }

    mapping(uint => NewProperty) public property;
    mapping(address => NewProperty[]) public house;
    mapping(uint => Lien) public liens;

    //Add new property..
    function addNewProperty(uint _cost, string memory _location, STATUS _status, PROPERTY_TYPE _type, address _ownerAddr)
        public
        payable
        onlyOwner
    {
        propertyCount += 1;
        property[propertyCount] = NewProperty(propertyCount, _cost, _location, _status, _type, _ownerAddr);

        NewProperty memory houses = NewProperty(
            {
                propertyId: propertyCount,
                cost: _cost,
                location: _location,
                status: _status,
                property_type: _type,
                ownerAddr: _ownerAddr
            });
        house[_ownerAddr].push(houses);
    }

    //Request Change of Ownership..
	function changeOwnership(uint id, address _buyer)
        public
        payable
        onlyOwner
        returns (address, STATUS status, bool _statusChange)
    {
	    // _buyer = 0x814D874D527eE258c315fE86B084Df58887cE5dF; //have to change the address to simulate the ether address on that day;
	    // _buyer == address(0);
		require(property[id].status == STATUS.PENDING, "");
	    require(property[id].ownerAddr != _buyer, "");

	    if (property[id].ownerAddr != _buyer) {
	        property[id].ownerAddr = _buyer;
	        property[id].status = STATUS.SOLD;
	        _statusChange = true;
    	    return (_buyer, status, _statusChange);
	    } else {
	        _statusChange = false;
    	    return (_buyer, status, _statusChange);
	    }
	}

    // Get all property details of an address..
    function creatingArrayForPropertiesNotSold(address propertyOwner)
        public
        returns (uint[] memory)
    {
        delete myArray;
        for (uint i = 0; i < (house[propertyOwner].length); i++) {
            if (house[propertyOwner][i].status != STATUS.SOLD) {
                myArray.push(house[propertyOwner][i].propertyId);
            }
	    }  return (myArray);
    }

    //get the Length of myArray which stores the ID of properties with status not sold for each address..
    function getLengthOfMyArray()
        public
        view
        returns (uint)
    {
        return myArray.length;
    }

    //get the length of the array..
    function getLengthArray(uint propertyCounter)
        public
        pure
        returns(uint)
    {
        return propertyCounter;
    }


    //Get the property details..
	function getPropertyDetails(uint id, address)
        public
        view
        returns (uint _id, uint cost, string memory location, STATUS status, address o)
    {
		return (id, property[id].cost, property[id].location, property[id].status, property[id].ownerAddr);
	}

    //Changing the Value of the property..
    function changeValue(uint id, uint _newValue)
        public
        payable
        onlyOwner
        returns (bool)
    {
        property[id].cost = _newValue;
        return true;
    }
}