const Contract = artifacts.require("Arbitration")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[1])
};
