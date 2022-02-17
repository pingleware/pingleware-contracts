# Social Network Token
The Social Network token is targeted to replace popular social networks by offering a community-driven content validation. An ideal blockchain social network woudl have each user mint a new token which creates a new contract and new address and now that user's data is segragated from the other users (see https://docs.tatum.io/guides/blockchain/how-to-create-erc-1155-multi-tokens about multi-tokens). While the social network is decentralized especially when deployed using IPFS and can be referenced using IPFS-contract address scheme, a centralized access point is used via a domain name. While an advertiser scheme can be built into  the contract, with the contract being opened source and viewable, transparency is automatic, so the users know when and how data integrity is maintained and protected.


# What is a Community-driven content validation?
The users decide which content is shown through thumps up and down voting. No voting status is shown to prevent mean spiritedness actions, and only one thumbs up and down vote is permitted per user. A thumbs up and down vote on a post, cancels that vote.

Additionally, having community owned data, anyone can create a new social network and interfacce with the existing libraries to leverage the existing user base and user news feeds. You new network will receive existing advertisements in your social network DAPP, and new advertisers that your network recruiters will be able to leverage the existing user based created by all social networks inetrfacing with the existing libraries. Everyone is sharing user stories and advertisements, and getting paid when a new post originates from your social network DAPP. Is this not what the definition of a Metaverse? (https://www.merriam-webster.com/words-at-play/meaning-of-metaverse)

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

# Earning Potential
To increase adoption of a new social network, there must be a direct benefit for the users. The earnings is an incentivizing benefit where a user can earn real money (cryptocurrency) for using the network.

## Owner/Contract Earnings
The owner of the contract want to earn for the time to develop and deploy this contract and dapp, and will earn in the following ways,

    - earns from user and advertiser registration
    - earns from user posting
    - earns from advertiser posting
    - earns from user list of wallets

## User Earnings
Unlike existing social networks that provide free, censored access and make money from your data without compensation, this social network contract
pays the user when

    - from comments to the posts
    - for each friend requests
    - for each follower
    - when a message is received from friend and follower via the wallet address
    - when a likes and dislikes are flag on your posts and comments

while the original post author receives earnings from comments, the comment author receives earnings from dislikes and likes on their comment


## Advertiser Earning
Using text-based advertising, an advertiser can post an advertisement that is shown in a designated area on the user's dapp,

  - earns from the sale of the product or service in their advertisement
