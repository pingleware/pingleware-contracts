const ForwardCurrency = artifacts.require("ForwardCurrency");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ForwardCurrency", function (/* accounts */) {
  it("should assert true", async function () {
    await ForwardCurrency.deployed();
    return assert.isTrue(true);
  });
});
