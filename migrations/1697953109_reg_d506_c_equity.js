const Contract = artifacts.require("RegD506CEquity")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"Regulation D Rule 506(c)","REGD506CX",200000,5,1000)
};
