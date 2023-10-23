const Contract = artifacts.require("RegD506CDebt")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"Regulation D Rule 506(c) Bond",200000,100,0)
};
