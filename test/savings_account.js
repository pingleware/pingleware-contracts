const SavingsAccount = artifacts.require("SavingsAccount");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SavingsAccount", function (/* accounts */) {
  it("should assert true", async function () {
    await SavingsAccount.deployed();
    return assert.isTrue(true);
  });
});
