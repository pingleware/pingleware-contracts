const Contract = artifacts.require("Reg147Debt")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};