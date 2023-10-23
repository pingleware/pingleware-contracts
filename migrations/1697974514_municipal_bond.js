const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange")
const ConsolidatedAuditTrail = artifacts.require("ConsolidatedAuditTrail")
const Contract = artifacts.require("MunicipalBond")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"GRU Bond",_accounts[1],17000000000,5,0,false,100000,ExemptLiquidityMarketExchange.address,ConsolidatedAuditTrail.address)
};
