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
    const auditTrailEntry = await contractInstance.getAuditTrail("SECT3A11EQUITY","0xfbe48ea79c515188a6f23ebfc3bb69de480f40b46f1a01154172806a3c23c995");
    if (!auditTrailEntry[0]) {
      // this is the first run, then add an emtry to the CAT
      const tx = await contractInstance.addAuditEntry("SECT3A11EQUITY", "Purchase shares", "purchase", "100 shares");
      assert.equal(tx.logs[0].args[0],"SECT3A11EQUITY","expected symbol to be SECT3A11EQUITY");  
    } else {
      // not the first test run, check to see if UTI matches expected
      if (auditTrailEntry[0][1] !== "0xfbe48ea79c515188a6f23ebfc3bb69de480f40b46f1a01154172806a3c23c995") {
        // UTI doesn't match, add an entry to the CAT
        const tx = await contractInstance.addAuditEntry("SECT3A11EQUITY", "Purchase shares", "purchase", "100 shares");
        assert.equal(tx.logs[0].args[0],"SECT3A11EQUITY","expected symbol to be SECT3A11EQUITY");  
      } else {
        return assert.isTrue(true);
      }
    }
  }) 
  it("get consolidate audit trail",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const tx = await contractInstance.getAuditTrail("SECT3A11EQUITY","0xfbe48ea79c515188a6f23ebfc3bb69de480f40b46f1a01154172806a3c23c995");
    console.log(tx);
    return assert.isTrue(true);
  })
  it("get consolidated audit trail complete",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const auditTrail = await contractInstance.getAuditTrailComplete();
    console.log(auditTrail);
    if (auditTrail[0]) {
      return assert.equal(auditTrail[0].symbol,"SECT3A11EQUITY","expected symbol to SECT3A11EQUITY")
    } else {
      return assert.isTrue(true);
    }
  })
  it("set exchange rate",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const tx = await contractInstance.setExchangeRate(1016);
    console.log(tx);
    if (tx.logs[0].args) {
      console.log(tx.logs[0].args);
    }
    return assert.isTrue(true)
  })
  it("get exchange rate",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const exchangeRate = await contractInstance.getExchangeRate();
    return assert.equal(exchangeRate.toNumber(),1016,"expected exchange rate to be $1,016");
  })
  it("wei to usd",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const usdAmount = await contractInstance.weiToUSD(6000000000);
    console.log(usdAmount.toNumber())
    return assert.isTrue(true)
  })
  it("usd to wei",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const weiAmount = await contractInstance.usdToWei(1000);
    console.log(BigInt(weiAmount));
    return assert.equal(BigInt(weiAmount),984251968503937007n,"expected Big Integer of 984251968503937007n");
  })
  it("usd to ether",async function(){
    const contractInstance = await ConsolidatedAuditTrail.deployed();
    const ethValue = await contractInstance.usdToEth(100);
    console.log(ethValue);
    return assert.equal(ethValue,0.98425196850393700,"expected ether value to be 0.98425196850393700");
  })
}); 
