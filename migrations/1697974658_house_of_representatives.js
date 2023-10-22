const Contract = artifacts.require("HouseOfRepresentatives")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract)
};
