const Reg701Equity = artifacts.require("Reg701Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/Reg701Equity", function (/* accounts */) {
  it("should assert true", async function () {
    await Reg701Equity.deployed();
    return assert.isTrue(true);
  });
});
