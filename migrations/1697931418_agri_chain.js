var AgriChain = artifacts.require("AgriChain");

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(AgriChain);
};
