const TouchCurrency = artifacts.require("TouchCurrency");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/currency/TouchCurrency", function (/* accounts */) {
  it("should assert true", async function () {
    await TouchCurrency.deployed();
    return assert.isTrue(true);
  });
});
