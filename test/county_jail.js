const CountyJail = artifacts.require("CountyJail");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/county/CountyJail", function (/* accounts */) {
  it("should assert true", async function () {
    await CountyJail.deployed();
    return assert.isTrue(true);
  });
});
