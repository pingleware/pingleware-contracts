const IRS = artifacts.require("IRS");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/federal/IRS", function (/* accounts */) {
  it("should assert true", async function () {
    await IRS.deployed();
    return assert.isTrue(true);
  });
});
