const Healthcare = artifacts.require("Healthcare");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Healthcare", function (/* accounts */) {
  it("should assert true", async function () {
    await Healthcare.deployed();
    return assert.isTrue(true);
  });
});
