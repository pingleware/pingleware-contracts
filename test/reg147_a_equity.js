const Reg147AEquity = artifacts.require("Reg147AEquity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Reg147AEquity", function (/* accounts */) {
  it("should assert true", async function () {
    await Reg147AEquity.deployed();
    return assert.isTrue(true);
  });
});
