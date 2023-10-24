const Contract = artifacts.require("TaxExemptBond")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"Amerione Corporation",_accounts[4],14000000,5,2013825599,1698124031,_accounts[1])
};
