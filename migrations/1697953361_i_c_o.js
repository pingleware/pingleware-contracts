const Contract = artifacts.require("ICO")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"https://ico.campaign",_accounts[4])
};
