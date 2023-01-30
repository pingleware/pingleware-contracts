// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library Advertiser {

    event AdvertiserAdded(address sender);
    event AdvertisementAdded(address sender, string message);
    event AdvertisementDeleted(address useraddress,string message,uint index);

    struct AdvertiserStorage {
        mapping (address => uint256) advertisers;
        mapping (address => string[]) advertisements;
        address[] _advertisers;
    }

    function advertiserStorage() internal pure returns (AdvertiserStorage storage ds)
    {
        bytes32 position = keccak256("advertiser.storage");
        assembly { ds.slot := position }
    }


    function isAdvertiser()
        external
        view
        returns (bool)
    {
        return (advertiserStorage().advertisers[msg.sender] != 0);
    }

    function notAdvertiser()
        external
        view
        returns (bool)
    {
        return (advertiserStorage().advertisers[msg.sender] == 0);
    }

    function addAdvertiser(address requestor)
        external
    {
        address advertiser = msg.sender;
        if (requestor != address(0x0)) {
            advertiser = requestor;
        }
        advertiserStorage().advertisers[advertiser] = 1;
        advertiserStorage()._advertisers.push(advertiser);
        emit AdvertiserAdded(advertiser);
    }

    function newAdvertisement(string memory message)
        external
    {
        advertiserStorage().advertisements[msg.sender].push(message);
        emit AdvertisementAdded(msg.sender, message);
    }

    function deleteAdvertisement(address advertiseraddr,uint index)
        external
    {
        if (advertiserStorage().advertisements[advertiseraddr].length > 0) {
            string memory message = advertiserStorage().advertisements[advertiseraddr][index];
            delete advertiserStorage().advertisements[advertiseraddr][index];
            emit AdvertisementDeleted(advertiseraddr,message,index);
        }
    }

    function getAdvertisements()
        external
        view
        returns (string[] memory)
    {
        return advertiserStorage().advertisements[msg.sender];
    }

    function getAdvertisers()
        external
        view
        returns (address[] memory)
    {
        return advertiserStorage()._advertisers;
    }

}