const OptionCurrency = artifacts.require("OptionCurrency");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/currency/OptionCurrency", function (/* accounts */) {
  it("should assert true", async function () {
    await OptionCurrency.deployed();
    return assert.isTrue(true);
  });
});
