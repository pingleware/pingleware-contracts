const InsuranceMotorVehicleServiceAgreement = artifacts.require("InsuranceMotorVehicleServiceAgreement");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("insurance/InsuranceMotorVehicleServiceAgreement", function (/* accounts */) {
  it("should assert true", async function () {
    await InsuranceMotorVehicleServiceAgreement.deployed();
    return assert.isTrue(true);
  });
});
