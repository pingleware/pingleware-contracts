// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library Advertiser {

    struct AdvertiserStorage {
        mapping (address => uint256) advertisers;
        mapping (address => string) advertisements;
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
    }

    function newAdvertisement(string memory message)
        external
    {
        advertiserStorage().advertisements[msg.sender] = message;
    }

    function getAdvertisers()
        external
        view
        returns (address[] memory)
    {
        return advertiserStorage()._advertisers;
    }

}