const ExchangeFee = artifacts.require("ExchangeFee")
const BestBooks = artifacts.require("BestBooks")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(ExchangeFee,BestBooks.address)
};
