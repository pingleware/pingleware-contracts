const FlashLoanArbitrage = artifacts.require("FlashLoanArbitrage");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/banking/FlashLoanArbitrage", function (/* accounts */) {
  it("should assert true", async function () {
    await FlashLoanArbitrage.deployed();
    return assert.isTrue(true);
  });
});
