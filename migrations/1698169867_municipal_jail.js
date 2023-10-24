const Contract = artifacts.require("MunicipalJail")
const MunicipalGovernment = artifacts.require("MunicipalGovernment")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,MunicipalGovernment.address)
};
