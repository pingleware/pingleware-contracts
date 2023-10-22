const Contract = artifacts.require("Reg147AEquity")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
