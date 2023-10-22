const RegD506CDebt = artifacts.require("RegD506CDebt");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RegD506CDebt", function (/* accounts */) {
  it("should assert true", async function () {
    await RegD506CDebt.deployed();
    return assert.isTrue(true);
  });
});
