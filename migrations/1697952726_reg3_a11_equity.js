const Contract = artifacts.require("Reg3A11Equity")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
