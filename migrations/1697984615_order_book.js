const Contract = artifacts.require("OrderBook")
const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange")
const ConsolidatedAuditTrail = artifacts.require("ConsolidatedAuditTrail")
const ExchangeFee = artifacts.require("ExchangeFee")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,ExemptLiquidityMarketExchange.address,ConsolidatedAuditTrail.address,ExchangeFee.address)
};
