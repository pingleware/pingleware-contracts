const AccidentHealth = artifacts.require("AccidentHealth");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("healthcare/AccidentHealth", function (/* accounts */) {
  it("should assert true", async function () {
    await AccidentHealth.deployed();
    return assert.isTrue(true);
  });
});
