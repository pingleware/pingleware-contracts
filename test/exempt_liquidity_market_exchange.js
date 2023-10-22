const ExemptLiquidityMarketExchange = artifacts.require("ExemptLiquidityMarketExchange");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ExemptLiquidityMarketExchange", function (/* accounts */) {
  it("should assert true", async function () {
    await ExemptLiquidityMarketExchange.deployed();
    return assert.isTrue(true);
  });
});
