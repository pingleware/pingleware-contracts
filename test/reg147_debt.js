const Reg147Debt = artifacts.require("Reg147Debt");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Reg147Debt", function (/* accounts */) {
  it("should assert true", async function () {
    await Reg147Debt.deployed();
    return assert.isTrue(true);
  });
});
