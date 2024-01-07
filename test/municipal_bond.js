const MunicipalBond = artifacts.require("MunicipalBond");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("government/municipal/MunicipalBond", function (/* accounts */) {
  it("should assert true", async function () {
    await MunicipalBond.deployed();
    return assert.isTrue(true);
  });
});
