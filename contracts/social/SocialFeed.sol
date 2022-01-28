// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library SocialFeeds {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);
    uint256 constant private negative = type(uint256).max;

    struct Post {
        uint256 epoch;
        bool    visible;
        string  content;
    }

    struct PostStorage {
        mapping (address => Post[]) postsV2;
        mapping (address => string[]) posts;
        address[] _posters;
    }

    function postStorage() internal pure returns (PostStorage storage ds)
    {
        bytes32 position = keccak256("post.storage");
        assembly { ds.slot := position }
    }

    event PostAdded(address sender, string message);

    function getPosters()
        external
        view
        returns (address[] memory)
    {
        return postStorage()._posters;
    }

    function getTotalPosters()
        external
        view
        returns (uint256)
    {
        return postStorage()._posters.length;
    }


    function addPostv2(uint256 epoch,bool visible,string memory content)
        external
    {
        Post memory _post = Post(epoch,visible,content);
        postStorage().postsV2[msg.sender].push(_post);
    }

    function getPostsv2()
        external
        view
        returns (Post[] memory)
    {
        return postStorage().postsV2[msg.sender];
    }

    function getPostsv2ByOwner(address owner)
        external
        view
        returns (Post[] memory)
    {
        return postStorage().postsV2[owner];
    }

    function getTotalPostsv2()
        external
        view
        returns (uint256)
    {
        return postStorage().postsV2[msg.sender].length;
    }

    function getTotalPostsv2ByOwner(address owner)
        external
        view
        returns (uint256)
    {
        return postStorage().postsV2[owner].length;
    }

    function addPostByOwner(string memory message)
        external
    {
        postStorage().posts[msg.sender].push(message);
    }

    function addPost(string memory message)
        external
        returns (uint256)
    {
        bool found = false;
        if (postStorage()._posters.length > 0) {
            for (uint i = 0; i < postStorage()._posters.length; i++) {
                if (postStorage()._posters[i] == ZERO_ADDRESS) {
                    found = true;
                }
            }
        }
        if (!found) {
            postStorage()._posters.push(msg.sender);
        }
        postStorage().posts[msg.sender].push(message);
        return postStorage().posts[msg.sender].length - 1;
    }

    function getTotalPosts()
        external
        view
        returns (uint256)
    {
        return postStorage().posts[msg.sender].length;
    }
    
    function getPosts(uint256 index)
        external
        view
        returns (string memory)
    {
        require(index < postStorage().posts[msg.sender].length,"post does not exists");
        return postStorage().posts[msg.sender][index];
    }
    

    function getAllPosts()
        external
        view
        returns (string memory)
    {
        string memory output = "";
        uint256 total = postStorage()._posters.length;
        for (uint i = 0; i < total; i++) {
            address key = postStorage()._posters[i];
            string[] memory post = postStorage().posts[key];
            if (post.length > 0) {
                for (uint l = 0; l < post.length; l++) {
                    output = string(abi.encodePacked(output, post[l]));
                }
            }
        }
        return output;
    }

}