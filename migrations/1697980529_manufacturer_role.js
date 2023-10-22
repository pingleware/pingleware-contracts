const Contract = artifacts.require("ManufacturerRole")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
