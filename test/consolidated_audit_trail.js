const ConsolidatedAuditTrail = artifacts.require("ConsolidatedAuditTrail");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/ConsolidatedAuditTrail", function (/* accounts */) {
  it("should assert true", async function () {
    await ConsolidatedAuditTrail.deployed();
    return assert.isTrue(true);
  });
  it("add an entry to the audit trail",async () => {
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const id = await contractInstance.addAuditEntry("SECT3A11EQUITY", "Purchase shares", "purchase", "100 shares")
    assert.equal(id.logs[0].event,"AuditEntryAdded","expected event to be AuditEntryAdded");
  })
});
