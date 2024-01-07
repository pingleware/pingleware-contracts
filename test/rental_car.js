const RentalCar = artifacts.require("RentalCar");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("transportation/RentalCar", function (/* accounts */) {
  it("should assert true", async function () {
    await RentalCar.deployed();
    return assert.isTrue(true);
  });
});
