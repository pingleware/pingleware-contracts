const SecurityMeta = artifacts.require("SecurityMeta");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("SecurityMeta", function (/* accounts */) {
  it("should assert true", async function () {
    await SecurityMeta.deployed();
    return assert.isTrue(true);
  });
});
