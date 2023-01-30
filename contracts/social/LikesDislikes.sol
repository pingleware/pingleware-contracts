// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library LikesDislikes {

    event LikeAdded(address sender,address poster,uint256 post);
    event DislikeAdded(address sender,address poster,uint256 post);

    struct LikesDislikesStorage {
        mapping (address => mapping(address => uint256)) likes;
        mapping (address => mapping(address => uint256)) dislikes;
    }

    function likesDislikesStorage() internal pure returns (LikesDislikesStorage storage ds)
    {
        bytes32 position = keccak256("likesdislikes.storage");
        assembly { ds.slot := position }
    }

    /**
    * a post may contain many likes, one -> many
    * one like per user per post
    */
    function setLike(uint256 post, address poster)
        external
    {
        require(msg.sender != address(0x0),"invalid sender");
        require(poster != address(0x0),"invalid post author");
        likesDislikesStorage().likes[msg.sender][poster] = post;
        emit LikeAdded(msg.sender,poster,post);
    }

    function setDislike(uint256 post, address poster)
        external
    {
        require(msg.sender != address(0x0),"invalid sender");
        require(poster != address(0x0),"invalid post author");
        likesDislikesStorage().dislikes[msg.sender][poster] = post;
        emit DislikeAdded(msg.sender,poster,post);
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