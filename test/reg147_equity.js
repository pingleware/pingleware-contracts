const Reg147Equity = artifacts.require("Reg147Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/Reg147Equity", function (/* accounts */) {
  it("should assert true", async function () {
    await Reg147Equity.deployed();
    return assert.isTrue(true);
  });
});
