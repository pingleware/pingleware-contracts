const ResellerRole = artifacts.require("ResellerRole");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ResellerRole", function (/* accounts */) {
  it("should assert true", async function () {
    await ResellerRole.deployed();
    return assert.isTrue(true);
  });
});