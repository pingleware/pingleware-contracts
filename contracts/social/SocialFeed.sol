// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library SocialFeeds {
    bytes32 constant private ZERO_BYTES = bytes32(0);
    address constant private ZERO_ADDRESS = address(0);

    event PostAdded(address sender, string message, uint index);
    event PostDeleted(address post, string message, uint index);

    struct Post {
        uint256 epoch;
        bool    visible;
        string  content;
    }

    struct PostStorage {
        mapping (address => Post[]) postsV2;
        mapping (address => string[]) posts;
        address[] _authors;
    }

    function postStorage() internal pure returns (PostStorage storage ds)
    {
        bytes32 position = keccak256("post.storage");
        assembly { ds.slot := position }
    }


    function getPosters()
        external
        view
        returns (address[] memory)
    {
        return postStorage()._authors;
    }

    function getTotalPosters()
        external
        view
        returns (uint256)
    {
        return postStorage()._authors.length;
    }


    function addPostv2(uint256 epoch,bool visible,string memory content)
        external
        returns (uint)
    {
        
        Post memory _post = Post(epoch,visible,content);
        postStorage().postsV2[msg.sender].push(_post);
        return postStorage().postsV2[msg.sender].length - 1;
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
        uint index = postStorage().posts[msg.sender].length - 1;
        emit PostAdded(msg.sender,message,index);
    }

    function addPost(string memory message)
        external
        returns (uint256)
    {
        bool found = false;
        if (postStorage()._authors.length > 0) {
            for (uint i = 0; i < postStorage()._authors.length; i++) {
                if (postStorage()._authors[i] == ZERO_ADDRESS) {
                    found = true;
                }
            }
        }
        if (!found) {
            postStorage()._authors.push(msg.sender);
        }
        postStorage().posts[msg.sender].push(message);
        uint index = postStorage().posts[msg.sender].length - 1;
        emit PostAdded(msg.sender,message,index);
        return index;
    }

    function removePost(address poster,uint index)
        external
    {
        if (postStorage().posts[poster].length > 0) {
            string memory message = postStorage().posts[poster][index];
            delete postStorage().posts[poster][index];
            emit PostDeleted(poster,message,index);
        }
    }

    function removePostByUser(uint index)
        external
    {
        if (postStorage().posts[msg.sender].length > 0) {
            string memory message = postStorage().posts[msg.sender][index];
            delete postStorage().posts[msg.sender][index];
            emit PostDeleted(msg.sender,message,index);
        }
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
        uint256 total = postStorage()._authors.length;
        for (uint i = 0; i < total; i++) {
            address key = postStorage()._authors[i];
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