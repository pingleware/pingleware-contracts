const BlockchainBNB = artifacts.require("BlockchainBNB");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("hospitality/BlockchainBNB", function (/* accounts */) {
  it("should assert true", async function () {
    await BlockchainBNB.deployed();
    return assert.isTrue(true);
  });
});
