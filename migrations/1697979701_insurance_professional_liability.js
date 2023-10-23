const Contract = artifacts.require("ProfessionalLiability")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
