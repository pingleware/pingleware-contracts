const NFTCollection = artifacts.require("NFTCollection");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("nft/NFTCollection", function (/* accounts */) {
  it("should assert true", async function () {
    await NFTCollection.deployed();
    return assert.isTrue(true);
  });
});
