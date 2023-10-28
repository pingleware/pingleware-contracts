const BondCertificate = artifacts.require("BondCertificate");
const Reg3A11Debt = artifacts.require("Reg3A11Debt");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/BondCertificate", function (accounts) {
  it("should assert true", async function () {
    await BondCertificate.deployed();
    return assert.isTrue(true);
  }); 
  it("create certificate", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const tokenInstance = await Reg3A11Debt.new();
    const tx = await bondCertificateInstance.createCertificate(tokenInstance.address,accounts[1],"Operations Investment Benefit",10000000,1635220799);
    if (tx.logs[0].args) {
      console.log(tx.logs[0].args[0].toNumber());
      return assert.equal(tx.logs[0].args[2],"Operations Investment Benefit","expected bond name of 'Operations Investment Benefit'");  
    } else {
      return assert.isTrue(true);
    }
  });
  it("get certificates by account[1]", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const bonds = await bondCertificateInstance.getCertificatesByOwner(accounts[1]);
    console.log(bonds);
    return assert.isTrue(true);
  });
  it("transfer certificate", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const tokenInstance = await Reg3A11Debt.new();
    const txCreated = await bondCertificateInstance.createCertificate(tokenInstance.address,accounts[1],"Operations Investment Benefit",10000000,1635220799);
    const tx = await bondCertificateInstance.transferCertificate(tokenInstance.address,accounts[1],txCreated.logs[0].args[0],accounts[2],10000000);
    if (tx.logs[0].args) {
      console.log(tx.logs[0].args);
    }
    return assert.isTrue(true);
  });
  it("get certificate balance", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const tokenInstance = await Reg3A11Debt.new();
    const txCreated = await bondCertificateInstance.createCertificate(tokenInstance.address,accounts[1],"Operations Investment Benefit",10000000,1635220799);
    const balance = await bondCertificateInstance.getCertificateBalance(tokenInstance.address,0);
    console.log(balance);
    return assert.isTrue(true);
  });
  it("get certificate for accounts[2]", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const bonds = await bondCertificateInstance.getCertificatesByOwner(accounts[2]);
    console.log(bonds);
    return assert.isTrue(true);
  });
  it("get certificate by number", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const bonds = await bondCertificateInstance.getCertificatesByOwner(accounts[2]);
    console.log(bonds);
    return assert.isTrue(true);
  });
  it("redeem bond", async function () {
    const bondCertificateInstance = await BondCertificate.deployed();
    const tokenInstance = await Reg3A11Debt.new();
    const txCreated = await bondCertificateInstance.createCertificate(tokenInstance.address,accounts[2],"Operations Investment Benefit",10000000,1635220799);
    console.log(txCreated);
    console.log(txCreated.logs[0].args);
    const tx = await bondCertificateInstance.redeemBond(tokenInstance.address,accounts[2],txCreated.logs[0].args[0].toNumber());
    if (tx.logs[0].args) {
      console.log(tx.logs[0].args);
    }
    return assert.isTrue(true);
  }); 
});
