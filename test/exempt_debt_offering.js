const ExemptDebtOffering = artifacts.require("ExemptDebtOffering");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ExemptDebtOffering", function (/* accounts */) {
  it("should assert true", async function () {
    await ExemptDebtOffering.deployed();
    return assert.isTrue(true);
  });
});
