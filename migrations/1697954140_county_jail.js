const Contract = artifacts.require("CountyJail")
const CountyGovernment = artifacts.require("CountyGovernment")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,CountyGovernment.address)
};
