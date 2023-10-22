const TokenManager = artifacts.require("TokenManager");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("TokenManager", function (/* accounts */) {
  it("should assert true", async function () {
    await TokenManager.deployed();
    return assert.isTrue(true);
  });
});
