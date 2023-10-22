const Contract = artifacts.require("WorkersCompensation")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
