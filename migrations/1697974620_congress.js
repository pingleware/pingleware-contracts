const Contract = artifacts.require("Congress")
const House = artifacts.require("HouseOfRepresentatives")
const Senate = artifacts.require("USSenate")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,House.address,Senate.address)
};
