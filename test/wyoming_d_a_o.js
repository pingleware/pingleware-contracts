const WyomingDAO = artifacts.require("WyomingDAO");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/dao/WyomingDAO", function (/* accounts */) {
  it("should assert true", async function () {
    await WyomingDAO.deployed();
    return assert.isTrue(true);
  });
});
