const Transaction = artifacts.require("Transaction");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Transaction", function (/* accounts */) {
  it("should assert true", async function () {
    await Transaction.deployed();
    return assert.isTrue(true);
  });
});
