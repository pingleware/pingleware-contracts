const HouseOfRepresentative = artifacts.require("HouseOfRepresentative");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/federal/HouseOfRepresentative", function (/* accounts */) {
  it("should assert true", async function () {
    await HouseOfRepresentative.deployed();
    return assert.isTrue(true);
  });
});
