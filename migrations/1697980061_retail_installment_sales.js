const Contract = artifacts.require("RetailInstallmentSales")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[3],1000,100,18)
};
