const StockCertificate = artifacts.require("StockCertificate");
const Reg3A11Equity = artifacts.require("Reg3A11Equity");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/StockCertificate", function (accounts) {
  it("should assert true", async function () {
    await StockCertificate.deployed();
    return assert.isTrue(true);
  });
  it("create certificate", async function () {
      const stockCertificateInstance = await StockCertificate.deployed();
      const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Section 3(a)(11) Equity","PRESS.3A11.X",4000000,5);
      const tx = await stockCertificateInstance.issueCertificate(tokenInstance.address,"PRESS.3A11.X",accounts[1],100);
      console.log(tx);
      if (tx.logs[0].args) {
        console.log(tx.logs[0].args);
        return assert.equal(tx.logs[0].args[2],"PRESS.3A11.X","expected bond name of 'PRESS.3A11.X'");  
      } else {
        return assert.isTrue(true);
      }
  });
  it("get certificate balance", async function () {
      const stockCertificateInstance = await StockCertificate.deployed();
      const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Section 3(a)(11) Equity","PRESS.3A11.X",4000000,5);
      const txIssued = await stockCertificateInstance.issueCertificate(tokenInstance.address,"PRESS.3A11.X",accounts[1],100);
      const certificateNo = txIssued.logs[0].args[0].toNumber();
      const balance = await stockCertificateInstance.getCertificateBalance(tokenInstance.address,certificateNo);
      console.log(balance.toNumber());
      return assert.equal(balance.toNumber(),100,"expected a balance of $100");
  });
  it("transfer certificate", async function () {
    const stockCertificateInstance = await StockCertificate.deployed();
    const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Section 3(a)(11) Equity","PRESS.3A11.X",4000000,5);
    const txIssued = await stockCertificateInstance.issueCertificate(tokenInstance.address,"PRESS.3A11.X",accounts[1],100);
    const certificateNo = txIssued.logs[0].args[0].toNumber();
    const tx = await stockCertificateInstance.transferCertificate(accounts[1],tokenInstance.address,certificateNo,accounts[2],10);
    console.log(tx);
    if (tx.logs[0].args) {
      console.log(tx.logs[0].args);
    }
    return assert.isTrue(true);
  });
  it("get certificate for accounts[2]", async function () {
    const stockCertificateInstance = await StockCertificate.deployed();
    const certificates = await stockCertificateInstance.getInvestorCertificates(accounts[2]);
    console.log(certificates);
    return assert.isTrue(true);
  });
  it("is certificate valid", async function () {
    const stockCertificateInstance = await StockCertificate.deployed();
    const tokenInstance = await Reg3A11Equity.new(accounts[1],"FL","Section 3(a)(11) Equity","PRESS.3A11.X",4000000,5);
    const txIssued = await stockCertificateInstance.issueCertificate(tokenInstance.address,"PRESS.3A11.X",accounts[1],100);
    const certificateNo = txIssued.logs[0].args[0].toNumber();
    const status = await stockCertificateInstance.isCertificateValid(tokenInstance.address,accounts[1],certificateNo);
    return assert.isTrue(status);
  });
});
