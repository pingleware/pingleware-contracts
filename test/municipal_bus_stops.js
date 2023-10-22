const MunicipalBusStops = artifacts.require("MunicipalBusStops");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("MunicipalBusStops", function (/* accounts */) {
  it("should assert true", async function () {
    await MunicipalBusStops.deployed();
    return assert.isTrue(true);
  });
});
