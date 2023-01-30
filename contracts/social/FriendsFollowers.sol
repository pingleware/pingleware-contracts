// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library FriendsFollowers {

    event FriendRequestApproved(address requestor);
    event NewFollowerAdded(address user, address follower);
    event NotifyFriends(address friend, string message);
    event FollowerDeleted(address sender,address _follower);
    event FriendDeleted(address sender,address _friend);

    struct FriendsFollowersStorage {
        mapping (address => address[]) followers;
        mapping (address => address[]) friend_requests;
        mapping (address => address[]) friends;
    }

    function friendsFollowersStorage() internal pure returns (FriendsFollowersStorage storage ds)
    {
        bytes32 position = keccak256("friendsfollowers.storage");
        assembly { ds.slot := position }
    }


    /**
     * Followers
     */
    function addFollower(address user)
        external
    {
        bool found = false;
        for (uint i = 0; i < friendsFollowersStorage().followers[user].length; i++) {
            if (friendsFollowersStorage().followers[user][i] == msg.sender) {
                found = true;
            }
        }
        require(found == false,"user is already being followed");
        friendsFollowersStorage().followers[user].push(msg.sender);
        emit NewFollowerAdded(user, msg.sender);
    }

    function removeFollower(address _user, address _follower)
        external
    {
        for (uint i = 0; i < friendsFollowersStorage().followers[_user].length; i++) {
            if (friendsFollowersStorage().followers[_user][i] == _follower) {
                delete friendsFollowersStorage().followers[_user][i];
                emit FollowerDeleted(_user, _follower);
            }
        }
    }

    function removeFriend(address _user, address _friend)
        external
    {
        for(uint i = 0; i < friendsFollowersStorage().friends[_user].length; i++) {
            if (friendsFollowersStorage().friends[_user][i] == _friend) {
                delete friendsFollowersStorage().friends[_user][i];
                emit FriendDeleted(_user,_friend);
            }
        }
    }

    function getFollowers()
        external
        view
        returns (address[] memory)
    {
        return friendsFollowersStorage().followers[msg.sender];
    }

    // Friend Request
    function addFriendRequest(address user)
        external
    {
        bool found = false;
        for (uint i = 0; i < friendsFollowersStorage().friend_requests[user].length; i++) {
            if (friendsFollowersStorage().friend_requests[user][i] == msg.sender) {
                found = true;
            }
        }
        require(found == false,"friend request is pending for this user");
        friendsFollowersStorage().friend_requests[user].push(msg.sender);
    }

    function getTotalFriendRequest()
        external
        view
        returns (uint256)
    {
        return friendsFollowersStorage().friend_requests[msg.sender].length;
    }

    function getTotalFriends()
        external
        view
        returns (uint256)
    {
        return friendsFollowersStorage().friends[msg.sender].length;
    }

    function getTotalFollowers()
        external
        view
        returns (uint256)
    {
        return friendsFollowersStorage().followers[msg.sender].length;
    }

    function getFriends()
        external
        view
        returns (address[] memory)
    {
        return friendsFollowersStorage().friends[msg.sender];
    }

    function getFriendRequest()
        external
        view
        returns (address[] memory)
    {
        return friendsFollowersStorage().friend_requests[msg.sender];
    }

    function approveFriendRequest(address requestor)
        external
    {
        for (uint i = 0; i < friendsFollowersStorage().friend_requests[msg.sender].length; i++) {
            if (friendsFollowersStorage().friend_requests[msg.sender][i] == requestor) {
                delete friendsFollowersStorage().friend_requests[msg.sender][i];
            }
        }
        friendsFollowersStorage().friends[msg.sender].push(requestor);
        emit FriendRequestApproved(requestor);
    }

    function deleteFriendRequest(address requestor)
        external
    {
        for (uint i = 0; i < friendsFollowersStorage().friend_requests[msg.sender].length; i++) {
            if (friendsFollowersStorage().friend_requests[msg.sender][i] == requestor) {
                delete friendsFollowersStorage().friend_requests[msg.sender][i];
            }
        }
    }

    function notifyFriends(string memory message)
        external
    {
        for (uint i = 0; i < friendsFollowersStorage().friends[msg.sender].length; i++) {
            payable(friendsFollowersStorage().friends[msg.sender][i]).transfer(0.0001 ether);
            emit NotifyFriends(friendsFollowersStorage().friends[msg.sender][i], message);
        }
    }

    function notifyFollowers(string memory message)
        external
    {
        for (uint i = 0; i < friendsFollowersStorage().followers[msg.sender].length; i++) {
            payable(friendsFollowersStorage().followers[msg.sender][i]).transfer(0.0001 ether);
            emit NotifyFriends(friendsFollowersStorage().followers[msg.sender][i], message);
        }
    }
}