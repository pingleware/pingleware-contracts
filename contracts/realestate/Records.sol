// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

/**
 * Records can eliminate title theft
 */

contract Records is Version, Owned {
    struct Folio {
        uint state;
        uint municipality;
        uint township;
        uint range;
        uint section;
        uint subsection;
        uint parcelid;
    }

    struct PropertyIdentifier {
        uint book;
        uint page;
        Folio folio;
        string legal_description;
        address owner;
        uint256 purchased_timestamp;
        string fips; // https://www2.census.gov/programs-surveys/decennial/2010/partners/pdf/FIPS_StateCounty_Code.pdf
    }

    mapping (address => mapping(string => mapping(string => PropertyIdentifier))) public property_records;

    event PropertyAdded(string fips,address current_owner,uint book,uint page,string folio,string legal_description,uint256 purchased);
    event PropertyTransferred(string fips,address current_owner,address new_owner, string folio, uint256 timestamp);

    constructor() {

    }

    modifier isCurrentOwner(string memory fips,string memory folio) {
        require(property_records[msg.sender][fips][folio].owner == msg.sender,"not the current owner");
        _;
    }

    /**
     * only the contract owner can add a new property. If property owner wallet is unknown, use the contract address as the default property owner
     * the updateOwner function can be used to change from contract default property owner to the real property owner
     */
    function addProperty(string memory fips,uint book,uint page,string memory folio,string memory legal_description,address current_owner,uint256 purchased) okOwner public {
        property_records[msg.sender][fips][folio] = PropertyIdentifier(book,page,stringToFolio(folio),legal_description,current_owner,purchased,fips);
        emit PropertyAdded(fips,current_owner,book,page,folio,legal_description,purchased);
    }

    function transfer(string memory fips,uint book,uint page, string memory folio, address new_owner) isCurrentOwner(fips,folio) public {
        PropertyIdentifier memory property = property_records[msg.sender][fips][folio];       
        property_records[new_owner][fips][folio] = PropertyIdentifier(book,page,stringToFolio(folio),property.legal_description,new_owner,block.timestamp,property.fips);
        property_records[msg.sender][fips][folio].owner = new_owner;
        emit PropertyTransferred(fips, msg.sender, new_owner, folio, block.timestamp);
    }

    function updateOwner(address new_owner, string memory fips, string memory folio) okOwner external {
        if (property_records[msg.sender][fips][folio].owner == msg.sender) {
            property_records[new_owner][fips][folio].owner = new_owner;
        }
    }

    // Function to convert Folio to string
    function folioToString(Folio memory folio) public pure returns (string memory) {
        return concatenate(
            uintToString(folio.state),
            uintToString(folio.municipality),
            uintToString(folio.township),
            uintToString(folio.range),
            uintToString(folio.section),
            uintToString(folio.subsection),
            uintToString(folio.parcelid)
        );
    }

    // Function to convert string back to Folio
    function stringToFolio(string memory str) public pure returns (Folio memory) {
        string[] memory parts = split(str, ", ");
        require(parts.length == 7, "Invalid input string");

        return Folio({
            state: stringToUint(parts[0]),
            municipality: stringToUint(parts[1]),
            township: stringToUint(parts[2]),
            range: stringToUint(parts[3]),
            section: stringToUint(parts[4]),
            subsection: stringToUint(parts[5]),
            parcelid: stringToUint(parts[6])
        });
    }

    // INTERNAL FUNCTIONS
    // Function to convert uint to string
    function uintToString(uint v) internal pure returns (string memory) {
        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length;
        while (v != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(v - v / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            v /= 10;
        }
        return string(bstr);
    }

    // Function to concatenate strings
    function concatenate(string memory a, string memory b, string memory c, string memory d, string memory e, string memory f, string memory g) internal pure returns (string memory) {
        return string(abi.encodePacked(a, ", ", b, ", ", c, ", ", d, ", ", e, ", ", f, ", ", g));
    }

    // Function to split a string by a delimiter
    function split(string memory _base, string memory _value) internal pure returns (string[] memory splitArr) {
        bytes memory _baseBytes = bytes(_base);
        uint _offset = 0;
        uint _splitsCount = 1;
        while (_offset < _baseBytes.length) {
            int _limit = indexOf(_base, _value, _offset);
            if (_limit == -1) break;
            else {
                _splitsCount++;
                _offset = uint(_limit) + bytes(_value).length;
            }
        }
        
        splitArr = new string[](_splitsCount);
        _offset = 0;
        _splitsCount = 0;
        while (_offset < _baseBytes.length) {
            int _limit = indexOf(_base, _value, _offset);
            if (_limit == -1) {
                _limit = int(_baseBytes.length);
            }
            string memory _tmp = new string(uint(_limit) - _offset);
            bytes memory _tmpBytes = bytes(_tmp);
            uint j = 0;
            for (uint i = _offset; i < uint(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint(_limit) + bytes(_value).length;
            splitArr[_splitsCount++] = string(_tmpBytes);
        }
        return splitArr;
    }

    // Function to find the index of the first occurrence of a substring
    function indexOf(string memory _base, string memory _value, uint _offset) internal pure returns (int) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);
        assert(_valueBytes.length == 1);
        for (uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int(i);
            }
        }
        return -1;
    }

    // Function to convert string to uint
    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
            if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57) {
                result = result * 10 + (uint8(b[i]) - 48);
            }
        }
        return result;
    }
}