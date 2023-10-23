const Contract = artifacts.require("NFTCollection")
const NFT = artifacts.require("NFT")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,NFT.address)
};
