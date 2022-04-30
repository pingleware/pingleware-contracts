// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract SoftwareLicenseMetadata {
    struct SoftwareLicenseData {
        address creator;
        string  name;
        string  upc;            // get a UPC code from https://www.gs1us.org/
        string  description;
        uint256 quantity;
        uint256 price;
        bytes32 image;
    }

    mapping (address => SoftwareLicenseData[]) public softwareLicenses;


    function addNewSoftwareLicense(address nftcontract,
                                   address creator,
                                   string memory name,
                                   string memory upc,
                                   string memory description,
                                   uint256 quantity,
                                   uint256 price,
                                   bytes32 image)
        public
        payable
    {
        SoftwareLicenseData memory license = SoftwareLicenseData(creator,name,upc,description,quantity,price,image);
        softwareLicenses[nftcontract].push(license);
    }
}