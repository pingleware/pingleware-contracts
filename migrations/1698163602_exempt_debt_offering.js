const Contract = artifacts.require("ExemptDebtOffering")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
