const Contract = artifacts.require("OrderBook")
const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange")
const ConsolidatedAuditTrail = artifacts.require("ConsolidatedAuditTrail")
const ExchangeFee = artifacts.require("ExchangeFee")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  // TODO: fix Error: ExchangeFee has no network configuration for its current network id (1697930746463).
  //_deployer.deploy(Contract,ExemptLiquidityMarketExchange.address,ConsolidatedAuditTrail.addres,ExchangeFee.address)
};
