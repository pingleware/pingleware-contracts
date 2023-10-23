const Contract = artifacts.require("PaymentWallet")

module.exports = function(_deployer, _network, _accounts) {
  // Use deployer to state migration tasks.
  const userAddress = _accounts[1];
  _deployer.deploy(Contract,userAddress)
};
