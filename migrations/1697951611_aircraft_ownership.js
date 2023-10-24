const Contract = artifacts.require("AircraftOwnership")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"Cessna 172-R","N-2023")
};
