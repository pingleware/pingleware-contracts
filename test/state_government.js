const StateGovernment = artifacts.require("StateGovernment");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/state/StateGovernment", function (/* accounts */) {
  it("should assert true", async function () {
    await StateGovernment.deployed();
    return assert.isTrue(true);
  });
});
