const BAToken = artifacts.require("BAToken");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/utility/BAToken", function (/* accounts */) {
  it("should assert true", async function () {
    await BAToken.deployed();
    return assert.isTrue(true);
  });
});
