const Contract = artifacts.require("MunicipalBusStops")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
