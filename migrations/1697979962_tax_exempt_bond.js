const Contract = artifacts.require("TaxExemptBond")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
