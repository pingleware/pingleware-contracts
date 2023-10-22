const Contract = artifacts.require("MotorVehicleServiceAgreement")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
