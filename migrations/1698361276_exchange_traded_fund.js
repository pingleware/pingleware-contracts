const Contract = artifacts.require("ExchangeTradedFund")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
