const FutureCurrency = artifacts.require("FutureCurrency");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("FutureCurrency", function (/* accounts */) {
  it("should assert true", async function () {
    await FutureCurrency.deployed();
    return assert.isTrue(true);
  });
});
