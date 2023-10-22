const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange");

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(ExemptLiquidityMarketExchange);
};
