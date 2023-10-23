const Contract = artifacts.require("NFT")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,"Ethereum Contract Creator License","ECC.LIC")
};
