const Contract = artifacts.require("Reg147Equity")
const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange")

module.exports = function(_deployer,_network,_accounts) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,_accounts[3],"FL","Regulation 147 Equity","REG147X",200000,5,ExemptLiquidityMarketExchange.address)
};
