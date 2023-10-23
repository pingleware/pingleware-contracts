const Contract = artifacts.require("Reg701Equity")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[3],"FL","Regulation 701 Equity","REG701X",500000,5)
};
