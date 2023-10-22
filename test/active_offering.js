const ActiveOffering = artifacts.require("ActiveOffering");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ActiveOffering", function (/* accounts */) {
  it("should assert true", async function () {
    await ActiveOffering.deployed();
    return assert.isTrue(true);
  });
});
