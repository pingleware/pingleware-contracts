const Contract = artifacts.require("ATS")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"RedeeCash-ELMX ATS")
};
