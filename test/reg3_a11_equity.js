const Reg3A11Equity = artifacts.require("Reg3A11Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/Reg3A11Equity", function (/* accounts */) {
  it("should assert true", async function () {
    await Reg3A11Equity.deployed();
    return assert.isTrue(true);
  });
});
