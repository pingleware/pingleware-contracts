const Contract = artifacts.require("Shares")
const TransferAgent = artifacts.require("TransferAgent")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  // TODO: fix Error: TransferAgent has no network configuration for its current network id (1697930746463).
  //_deployer.deploy(Contract,TransferAgent.address)
};
