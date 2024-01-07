const DelawareStockToken = artifacts.require("DelawareStockToken");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/equity/DelawareStockToken", function (/* accounts */) {
  it("should assert true", async function () {
    await DelawareStockToken.deployed();
    return assert.isTrue(true);
  });
});
