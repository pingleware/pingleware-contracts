const CountyGovernment = artifacts.require("CountyGovernment");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/county/CountyGovernment", function (/* accounts */) {
  it("should assert true", async function () {
    await CountyGovernment.deployed();
    return assert.isTrue(true);
  });
});
