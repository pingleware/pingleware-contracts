const Contract = artifacts.require("DisputeResolution")
const Arbitration = artifacts.require("Arbitration")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,Arbitration.address)
};
