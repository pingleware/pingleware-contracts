const Contract = artifacts.require("Shares")
const TransferAgent = artifacts.require("TransferAgent")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,TransferAgent.address)
};
