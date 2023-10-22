const Contract = artifacts.require("RegAT1Equity")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
