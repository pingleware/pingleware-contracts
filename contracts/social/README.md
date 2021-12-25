# Social Network Token
The Social Network token is targeted to replace popular social networks by offering a community-driven content validation. An ideal blockchain social network woudl have each user mint a new token which creates a new contract and new address and now that user's data is segragated from the other users (see https://docs.tatum.io/guides/blockchain/how-to-create-erc-1155-multi-tokens about multi-tokens). While the social network is decentralized especially when deployed using IPFS and can be referenced using IPFS-contract address scheme, a centralized access point is used via a domain name. While an advertiser scheme can be built into  the contract, with the contract being opened source and viewable, transparency is automatic, so the users know when and how data integrity is maintained and protected.

# What is a Community-driven content validation?
The users decide which content is shown through thumps up and down voting. No voting status is shown to prevent mean spiritedness actions, and only one thumbs up and down vote is permitted per user. A thumbs up and down vote on a post, cancels that vote.

# User roles
The are three user roles: owner (single account), advertiser and user. The advertiser places text-only advertisements that are viewable at a dedicated location of the user's page.

# Methods based on user role
The following methods are available, and accessible by the user role.

## All Users

    addPost - adds a new post index by the user wallet address, user must exist whether advertiser or a user
    updateUserMeta - adds additional user meta information: profession, location, dob and interests
    getCommentTotal - obtains the total number of comments for a user
    getComment - retrieves a single comment for a user by the comment index
    getTotalPosts - obtains the total posts for a specific user
    getPost - obtain a single post for the logged in user
    getUserRole - determines the logged in user's role

## Owner

    addPostByOwner - a owner post creation without the validation
    getAdvertisers - gets an array all of the advertisers
    getUsers - gets an array of all of the users

## Advertiser

    addAdvertiser - adds a new user as an advertiser based on their waller address
    newAdvertisement - creates a new text advertisement

## User

    addUser - adds a regular user to the network using their wallet address
    setDislike - sets the dislike flag on an existing user's post
    setLike - sets the like flag on an existing iser's post
    addFollower - set users you wish to follow
    getFollowers - get an array of users you are following
    addFriendRequest - set a friend request
    getTotalFriendRequest - get your total friend requests
    getFriendRequest - get your friend request