const Reg147ADebt = artifacts.require("Reg147ADebt");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/Reg147ADebt", function (/* accounts */) {
  it("should assert true", async function () {
    await Reg147ADebt.deployed();
    return assert.isTrue(true);
  });
});
