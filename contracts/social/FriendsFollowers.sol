// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library FriendsFollowers {

    struct FriendsFollowersStorage {
        mapping (address => address) followers;
        mapping (address => mapping(address => bool)) friend_request;
        mapping (address => address) friends;
        address[] _friends;
    }

    function friendsFollowersStorage() internal pure returns (FriendsFollowersStorage storage ds)
    {
        bytes32 position = keccak256("advertiser.storage");
        assembly { ds.slot := position }
    }



    /**
     * Followers
     */
    function addFollower(address user)
        external
    {
        friendsFollowersStorage().followers[msg.sender] = user;
    }

    function getFollowers()
        external
        view
        returns (address)
    {
        return friendsFollowersStorage().followers[msg.sender];
    }

    // Friend Request
    function addFriendRequest(address user)
        external
    {
        bool found1 = false;
        bool found2 = false;
        for (uint i = 0; i < friendsFollowersStorage()._friends.length; i++) {
            if (friendsFollowersStorage()._friends[i] == user) {
                found1 = true;
            }
            if (friendsFollowersStorage()._friends[1] == msg.sender) {
                found2 = true;
            }
        }
        if (found1) {
            friendsFollowersStorage()._friends.push(user);
        }
        if (found2) {
            friendsFollowersStorage()._friends.push(msg.sender);
        }
        friendsFollowersStorage().friend_request[user][msg.sender] = true;
        friendsFollowersStorage().friend_request[msg.sender][user] = true;
    }

    function getTotalFriendRequest()
        external
        view
        returns (uint256)
    {
        uint total = 0;
        for (uint i = 0; i < friendsFollowersStorage()._friends.length; i++) {
            if (friendsFollowersStorage().friend_request[msg.sender][friendsFollowersStorage()._friends[i]]) {
                total++;
            }
        }
        return total;
    }

    function getFriends()
        external
        view
        returns (address[] memory)
    {
        return friendsFollowersStorage()._friends;
    }

    function getFriendRequest()
        external
        view
        returns (string memory)
    {
        string memory output = "";
        for (uint i = 0; i < friendsFollowersStorage()._friends.length; i++) {
            if (friendsFollowersStorage().friend_request[msg.sender][friendsFollowersStorage()._friends[i]]) {
                output = string(abi.encodePacked(friendsFollowersStorage()._friends[1]));
            }
        }
        return output;
    }

}