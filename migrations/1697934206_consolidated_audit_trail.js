const ConsolidatedAuditTrail = artifacts.require("ConsolidatedAuditTrail")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(ConsolidatedAuditTrail)
};