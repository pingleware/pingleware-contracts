const Arbitration = artifacts.require("Arbitration");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Arbitration", function (/* accounts */) {
  it("should assert true", async function () {
    await Arbitration.deployed();
    return assert.isTrue(true);
  });
});
