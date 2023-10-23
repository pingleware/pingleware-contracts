const Contract = artifacts.require("SCOTUS")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[1],[_accounts[2],_accounts[3],_accounts[4],_accounts[5],_accounts[6],_accounts[7],_accounts[8],_accounts[9]])
};
