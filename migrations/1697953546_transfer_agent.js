const Contract = artifacts.require("TransferAgent")
const Transaction = artifacts.require("Transaction")
const ActiveOffering = artifacts.require("ActiveOffering")
const Shareholder = artifacts.require("Shareholder")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Shareholder)
  _deployer.link(Shareholder,Contract)
  _deployer.deploy(Contract,_accounts[9],Transaction.address,ActiveOffering.address)
};
