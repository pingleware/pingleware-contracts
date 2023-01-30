var StringUtils = artifacts.require('./StringUtils');
var Advertiser = artifacts.require('./Advertiser');
var Comment = artifacts.require('./Comment');
var ECVerify = artifacts.require('./ECVerify');
var FriendsFollowers = artifacts.require('./FriendsFollowers');
var SocialFeeds = artifacts.require('./SocialFeeds');
var User = artifacts.require('./User');
var SocialNetwork = artifacts.require('./SocialNetwork');

module.exports = function(deployer, network, accounts) {
     if (network == "nodeploy") return;
     // deploy libraries
     deployer.deploy(StringUtils);
     deployer.deploy(Advertiser);
     deployer.deploy(Comment);
     deployer.deploy(ECVerify);
     deployer.deploy(FriendsFollowers);
     deployer.deploy(SocialFeeds);
     deployer.deploy(User);   
     // link libraries to contract
     deployer.link(StringUtils, SocialNetwork);
     deployer.link(Advertiser, SocialNetwork);
     deployer.link(Comment, SocialNetwork);
     deployer.link(ECVerify, SocialNetwork);
     deployer.link(FriendsFollowers, SocialNetwork);
     deployer.link(SocialFeeds, SocialNetwork);
     deployer.link(User, SocialNetwork);
     // deploy contract
     deployer.deploy(SocialNetwork);
}
