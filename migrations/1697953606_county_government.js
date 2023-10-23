const Contract = artifacts.require("CountyGovernment")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"Alachua","Florida")
};
