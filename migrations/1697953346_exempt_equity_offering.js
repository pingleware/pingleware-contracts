const Contract = artifacts.require("ExemptEquityOffering")
const UserAccount = artifacts.require("UserAccount")
const TransferAgent = artifacts.require("TransferAgent")
const Shares = artifacts.require("Shares")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,0,UserAccount.address,TransferAgent.address,Shares.address,200000)
};
