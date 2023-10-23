const Contract = artifacts.require("SocialNetwork")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  // TODO: fix "SocialNetwork" -- SocialNetwork contains unresolved libraries. You must deploy and link the following libraries before you can deploy a new version of SocialNetwork: Advertiser, Comment, FriendsFollowers, SocialFeeds, StringUtils, User.
  //_deployer.deploy(Contract)
};
