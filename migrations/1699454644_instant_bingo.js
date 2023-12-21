const Contract = artifacts.require("InstantBingo");

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"AMERIONE CORPORATION");
};
