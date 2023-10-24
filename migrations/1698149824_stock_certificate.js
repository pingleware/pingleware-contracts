const StockCertificate = artifacts.require("StockCertificate")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(StockCertificate)
};
