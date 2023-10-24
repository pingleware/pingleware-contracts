const Contract = artifacts.require("DirectEquityOffering")
const Reg3A11Equity = artifacts.require("Reg3A11Equity")
const TransferAgent = artifacts.require("TransferAgent")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,12,Reg3A11Equity.address,TransferAgent.address,4000000,5,5)
};
