// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

library Comment {

    event NewCommentAdded(address poster);

    struct CommentItem {
        address comment_author;
        uint256 post_index;
        string  message;
    }

    struct CommentStorage {
        mapping (address => CommentItem[]) comments;
        address[] comment_keys;
    }

    function commentStorage() internal pure returns (CommentStorage storage ds)
    {
        bytes32 position = keccak256("comment.storage");
        assembly { ds.slot := position }
    }


    function addComment(address poster, uint index, string memory message)
        external
    {
        bool found = false;
        if (commentStorage().comment_keys.length > 0) {
            for (uint i = 0; i < commentStorage().comment_keys.length; i++) {
                if (commentStorage().comment_keys[i] == poster) {
                found = true;
                }
            }
        }
        if (!found) {
            commentStorage().comment_keys.push(poster);
        }
        address comment_author = msg.sender;
        CommentItem memory comment = CommentItem(comment_author, index, message);
        commentStorage().comments[poster].push(comment);
        emit NewCommentAdded(poster);
    }

    function getCommentTotal(address poster)
        external
        view
        returns (uint256)
    {
        return commentStorage().comments[poster].length;
    }

    function getComments()
        external
        view
        returns (CommentItem[] memory)
    {
        return commentStorage().comments[msg.sender];
    }

    function getCommentsForPoster(address poster)
        external
        view
        returns (CommentItem[] memory)
    {
        return commentStorage().comments[poster];
    }


}