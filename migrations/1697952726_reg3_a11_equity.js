const Contract = artifacts.require("Reg3A11Equity")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[3],"FL","Regulation 3(a)(11) Equity","REG3A11X",200000,5)
};
