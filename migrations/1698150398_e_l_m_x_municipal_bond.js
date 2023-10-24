const Contract = artifacts.require("ELMXMunicipalBond")
const ExemptLiquidityMarketyExchange = artifacts.require("ExemptLiquidityMarketExchange")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"GRU Debt Bond",_accounts[4],17000000000,3,2013825599,false,10000000,ExemptLiquidityMarketyExchange.address)
};
