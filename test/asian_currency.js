const AsianCurrency = artifacts.require("Asian");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/currency/Asian", function (accounts) {
  it("should assert true", async function () {
    await AsianCurrency.deployed();
    return assert.isTrue(true);
  });
});
