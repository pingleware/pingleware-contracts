const CreditReportAgency = artifacts.require("CreditReportAgency");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CreditReportAgency", function (/* accounts */) {
  it("should assert true", async function () {
    await CreditReportAgency.deployed();
    return assert.isTrue(true);
  });
});
