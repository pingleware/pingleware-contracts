const Contract = artifacts.require("WyomingDAO")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"WY Exempt Investment Club")
};
