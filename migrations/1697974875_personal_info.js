const Contract = artifacts.require("PersonalInfo")
const User = artifacts.require("User")
const StringUtils = artifacts.require("StringUtils")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(StringUtils)
  _deployer.link(StringUtils,User)
  _deployer.deploy(User)
  _deployer.link(User,Contract)
  // TODO: fix PersonalInfo" hit a require or revert statement with the following reason given:
  //             * unauthorized access, sender not an owner
  //_deployer.deploy(Contract)
};
