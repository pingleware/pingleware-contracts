const RideshareTrade = artifacts.require("RideshareTrade");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RideshareTrade", function (/* accounts */) {
  it("should assert true", async function () {
    await RideshareTrade.deployed();
    return assert.isTrue(true);
  });
});