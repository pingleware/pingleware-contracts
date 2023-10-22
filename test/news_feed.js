const NewsFeed = artifacts.require("NewsFeed");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("NewsFeed", function (/* accounts */) {
  it("should assert true", async function () {
    await NewsFeed.deployed();
    return assert.isTrue(true);
  });
});
