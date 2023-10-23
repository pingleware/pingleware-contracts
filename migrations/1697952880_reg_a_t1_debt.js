const Contract = artifacts.require("RegAT1Debt")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
