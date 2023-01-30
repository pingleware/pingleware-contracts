// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;


library Subscriber {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    struct SubscriberStorage {
        mapping(address => uint256) subscribers;
        address[] _subscribers;
    }

    function subscriberStorage() internal pure returns (SubscriberStorage storage ds)
    {
        bytes32 position = keccak256("subscriber.storage");
        assembly { ds.slot := position }
    }


    function onlySubscriber()
        external
        view
        returns (bool)
    {
        return (subscriberStorage().subscribers[msg.sender] != 0);
    }

    function isSubscriber(address addr)
        external
        view
        returns (bool)
    {
        return (subscriberStorage().subscribers[addr] != 0);
    }

    function alreadySubscriber(address addr)
        internal
        view
        returns (bool)
    {
        bool found = false;
        for (uint i = 0; i < subscriberStorage()._subscribers.length; i++) {
            if (subscriberStorage()._subscribers[i] == addr) {
                found = true;
            }
        }
        return found;
    }

    function addSubscriber(address addr, uint256 _type)
        internal
        returns (bool)
    {
        if (alreadySubscriber(addr) == false) {
            subscriberStorage().subscribers[addr] = _type;
            subscriberStorage()._subscribers.push(addr);
            return true;
        }
        return false;
    }

    function getSubscribers()
        external
        view
        returns (address[] memory)
    {
        return subscriberStorage()._subscribers;
    }

}