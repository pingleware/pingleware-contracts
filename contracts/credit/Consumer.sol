// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library Consumer {
    struct ConsumerStorage {
        mapping(address => uint256) consumers;
        address[] _consumers;
    }

    function consumerStorage() internal pure returns (ConsumerStorage storage ds)
    {
        bytes32 position = keccak256("consumer.storage");
        assembly { ds.slot := position }
    }

    function onlyConsumer()
        external
        view
        returns (bool)
    {
        return (consumerStorage().consumers[msg.sender] != 0);
    }

    function isConsumer(address addr)
        external
        view
        returns (bool)
    {
        return (consumerStorage().consumers[addr] != 0);
    }


    function alreadyConsumer(address addr)
        external
        view
        returns (bool)
    {
        bool found = false;
        for (uint i = 0; i < consumerStorage()._consumers.length; i++) {
            if (consumerStorage()._consumers[i] == addr) {
                found = true;
            }
        }
        return found;
    }

    function getConsumers()
        external
        view
        returns (address[] memory)
    {
        return consumerStorage()._consumers;
    }


}