const Contract = artifacts.require("DelawareStockToken")
const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  const registryAddress = ExemptLiquidityMarketExchange.address;
  _deployer.deploy(Contract,"Delaware Company","DE.EQUITY",200000,"ByLaws",registryAddress)
};
