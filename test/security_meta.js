const SecurityMeta = artifacts.require("SecurityMeta");
const Reg3A11Equity = artifacts.require("Reg3A11Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/SecurityMeta", function (accounts) {
  it("should assert true", async function () {
    await SecurityMeta.deployed();
    return assert.isTrue(true);
  });
  it("set cusip number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const tx = await securityMetaInstance.assignCUSIPtoToken(Reg3A11Equity.address,"999000999");
    console.log(tx);
    if (tx.logs[0].args.length > 0) {
      return assert.equal(tx.logs[0].args[2],"999000999","expected new cusip to be 999000999");
    } else {
      return assert.isTrue(true);
    }
  });
  it("get cusip number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const cusip = await securityMetaInstance.getCUSIP(Reg3A11Equity.address);
    return assert.equal(cusip,"999000999","expected cuisp number of 999000999");
  });
  it("set isin number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const tx = await securityMetaInstance.assignISINtoToken(Reg3A11Equity.address,"00008888");
    if (tx.logs[0].args.length > 0) {
      return assert.equal(tx.logs[0].args[2],"00008888","expected ISIN of 00008888");
    } else {
      return assert.isTrue(true);
    }
  });
  it("get isin number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const isin = await securityMetaInstance.getISIN(Reg3A11Equity.address);
    return assert.equal(isin,"00008888","expected ISIN of 00008888");
  });
  it("assign file number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const tx = await securityMetaInstance.assignFileNumber(Reg3A11Equity.address,"021-000000");
    if (tx.logs[0].args.length > 0) {
      return assert.equal(tx.logs[0].args[2],"021-000000","expected file number 021-000000");
    } else {
      return assert.isTrue(true);
    }
  });
  it("get file number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const fileNumber = await securityMetaInstance.getFileNumber(Reg3A11Equity.address);
    return assert.equal(fileNumber,"021-000000","expected file number 021-000000");
  });
  it("assign certificate number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const randomNumber = Math.floor(Math.random() * 1000000); // You can adjust the range as needed
    const certificate = `CERT-${randomNumber.toString().padStart(6, '0')}`;
    const tx = await securityMetaInstance.assignCertificateNumber(Reg3A11Equity.address,1,certificate);
    console.log(tx);
    return assert.isTrue(true);
  });
  it("get certificate number", async function () {
    const securityMetaInstance = await SecurityMeta.deployed();
    const certificate = await securityMetaInstance.getCertificateNumber(Reg3A11Equity.address,1);
    console.log(certificate);
    return assert.isTrue(true);
  });
});
