const Congress = artifacts.require("Congress");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Congress", function (/* accounts */) {
  it("should assert true", async function () {
    await Congress.deployed();
    return assert.isTrue(true);
  });
});
