const RealEstateRecords = artifacts.require("RealEstateRecords");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("realestate/RealEstateRecords", function (/* accounts */) {
  it("should assert true", async function () {
    await RealEstateRecords.deployed();
    return assert.isTrue(true);
  });
});
