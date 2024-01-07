const Classifieds = artifacts.require("Classifieds");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("retail/Classifieds", function (/* accounts */) {
  it("should assert true", async function () {
    await Classifieds.deployed();
    return assert.isTrue(true);
  });
});
