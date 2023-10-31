const RedeecashExchange = artifacts.require("RedeecashExchange");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("RedeecashExchange", function (/* accounts */) {
  it("should assert true", async function () {
    await RedeecashExchange.deployed();
    return assert.isTrue(true);
  });
});
