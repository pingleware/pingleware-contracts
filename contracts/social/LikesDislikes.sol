// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library LikesDislikes {

    struct LikesDislikesStorage {
        mapping (address => mapping(address => uint256)) likes;
        mapping (address => mapping(address => uint256)) dislikes;
    }

    function likesDislikesStorage() internal pure returns (LikesDislikesStorage storage ds)
    {
        bytes32 position = keccak256("diamond.standard.account.storage");
        assembly { ds.slot := position }
    }

    /**
    * a post may contain many likes, one -> many
    * one like per user per post
    */
    function setLike(uint256 post, address poster, address user)
        external
    {
        likesDislikesStorage().likes[user][poster] = post;
    }

    function setDislike(uint256 post, address poster, address user)
        external
    {
        likesDislikesStorage().dislikes[user][poster] = post;
    }

    function getLikes(address user, address poster)
        external
        view
        returns (uint256)
    {
        return likesDislikesStorage().likes[user][poster];
    }

    function getDislikes(address user, address poster)
        external
        view
        returns (uint256)
    {
        return likesDislikesStorage().dislikes[user][poster];
    }

}