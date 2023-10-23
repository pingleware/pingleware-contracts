const Contract = artifacts.require("PersonalInfo")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  // TODO: fix "PersonalInfo" -- PersonalInfo contains unresolved libraries. You must deploy and link the following libraries before you can deploy a new version of PersonalInfo: User.
  //_deployer.deploy(Contract)
};
