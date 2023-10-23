const Contract = artifacts.require("CPAMM")
const RegD506CEquity = artifacts.require("RegD506CEquity")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,RegD506CEquity.address,RegD506CEquity.address)
};
