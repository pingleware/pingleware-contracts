const RegAT1Debt = artifacts.require("RegAT1Debt");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/RegAT1Debt", function (/* accounts */) {
  it("should assert true", async function () {
    await RegAT1Debt.deployed();
    return assert.isTrue(true);
  });
});
