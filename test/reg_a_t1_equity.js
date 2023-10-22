const RegAT1Equity = artifacts.require("RegAT1Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RegAT1Equity", function (/* accounts */) {
  it("should assert true", async function () {
    await RegAT1Equity.deployed();
    return assert.isTrue(true);
  });
});
