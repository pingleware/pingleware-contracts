const TransferAgent = artifacts.require("TransferAgent");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("TransferAgent", function (/* accounts */) {
  it("should assert true", async function () {
    await TransferAgent.deployed();
    return assert.isTrue(true);
  });
});
