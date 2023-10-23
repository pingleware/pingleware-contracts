const AircraftOwnership = artifacts.require("AircraftOwnership");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("aviation/AircraftOwnership", function (/* accounts */) {
  it("should assert true", async function () {
    await AircraftOwnership.deployed();
    return assert.isTrue(true);
  });
});
