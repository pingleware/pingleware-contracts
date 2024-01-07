const UserAccount = artifacts.require("UserAccount");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/UserAccount", function (/* accounts */) {
  it("should assert true", async function () {
    await UserAccount.deployed();
    return assert.isTrue(true);
  });
});
