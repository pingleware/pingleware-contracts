const Contract = artifacts.require("ExemptDebtOfferingStaking")
const Transaction = artifacts.require("Transaction")

module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(Contract,Transaction.address,12,2000000)
};
