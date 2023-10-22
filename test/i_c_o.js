const ICO = artifacts.require("ICO");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ICO", function (/* accounts */) {
  it("should assert true", async function () {
    await ICO.deployed();
    return assert.isTrue(true);
  });
});
