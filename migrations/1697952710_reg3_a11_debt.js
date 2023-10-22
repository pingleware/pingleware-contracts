const Contract = artifacts.require("Reg3A11Debt")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
