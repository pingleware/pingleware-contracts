const Contract = artifacts.require("TransferAgent")
const Transaction = artifacts.require("Transaction")
const ActiveOffering = artifacts.require("ActiveOffering")
const Shareholder = artifacts.require("Shareholder")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  // TODO: debug "TransferAgent" -- TransferAgent contains unresolved libraries. You must deploy and link the following libraries before you can deploy a new version of TransferAgent: Shareholder.
  //_deployer.deploy(Contract,_accounts[9],Transaction.address,ActiveOffering.address)
};
