const Contract = artifacts.require("CountyBusStops")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
