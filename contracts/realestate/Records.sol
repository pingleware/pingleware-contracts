// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

/**
 * Records can eliminate title theft
 */

contract Records is Version, Owned {
    struct PropertyIdentifier {
        uint book;
        uint page;
        string folio;
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
        property_records[msg.sender][fips][folio] = PropertyIdentifier(book,page,folio,legal_description,current_owner,purchased,fips);
        emit PropertyAdded(fips,current_owner,book,page,folio,legal_description,purchased);
    }

    function transfer(string memory fips,uint book,uint page, string memory folio, address new_owner) isCurrentOwner(fips,folio) public {
        PropertyIdentifier memory property = property_records[msg.sender][fips][folio];       
        property_records[new_owner][fips][folio] = PropertyIdentifier(book,page,folio,property.legal_description,new_owner,block.timestamp,property.fips);
        property_records[msg.sender][fips][folio].owner = new_owner;
        emit PropertyTransferred(fips, msg.sender, new_owner, folio, block.timestamp);
    }

    function updateOwner(address new_owner, string memory fips, string memory folio) okOwner external {
        if (property_records[msg.sender][fips][folio].owner == msg.sender) {
            property_records[new_owner][fips][folio].owner = new_owner;
        }
    }
}