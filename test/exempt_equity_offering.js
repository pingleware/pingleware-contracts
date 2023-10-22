const ExemptEquityOffering = artifacts.require("ExemptEquityOffering");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ExemptEquityOffering", function (/* accounts */) {
  it("should assert true", async function () {
    await ExemptEquityOffering.deployed();
    return assert.isTrue(true);
  });
});
