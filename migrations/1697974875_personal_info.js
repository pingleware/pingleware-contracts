const Contract = artifacts.require("PersonalInfo")
const User = artifacts.require("User")
const StringUtils = artifacts.require("StringUtils")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(StringUtils)
  _deployer.link(StringUtils,User)
  _deployer.deploy(User)
  _deployer.link(User,Contract)
  _deployer.deploy(Contract)
};
