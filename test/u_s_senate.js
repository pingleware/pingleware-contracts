const USSenate = artifacts.require("USSenate");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("USSenate", function (/* accounts */) {
  it("should assert true", async function () {
    await USSenate.deployed();
    return assert.isTrue(true);
  });
});