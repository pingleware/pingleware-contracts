const Contract = artifacts.require("RegAT1Equity")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[3],"FL","Regulation A Tier 1 Equity","REGAT1X",200000,5)
};
