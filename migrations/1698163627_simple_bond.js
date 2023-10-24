const Contract = artifacts.require("SimpleBond")
const Token = artifacts.require("DebtToken")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Token)
  _deployer.deploy(Contract,"Simple Bond",5,2,5,15,10000000,2013825599,Token.address,100)
};
