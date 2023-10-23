const Contract = artifacts.require("InsuranceQuote")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
