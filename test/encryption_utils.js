const EncryptionUtils = artifacts.require("EncryptionUtils");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/EncryptionUtils", function (/* accounts */) {
  it("should assert true", async function () {
    await EncryptionUtils.deployed();
    return assert.isTrue(true);
  });
  it("encrypt",async function(){
    const encryptionUtilsInstance = await EncryptionUtils.deployed();
    const encrypted = await encryptionUtilsInstance.encrypt("Exempt Liquidity Market Exchange","ELMX");
    return assert.equal(encrypted,"0x8ac4b2c5b5c06da4aebdc2c1a9b5c1d16599aecab0b1c1788ac4b0c0a6bab4bd","expected 0x8ac4b2c5b5c06da4aebdc2c1a9b5c1d16599aecab0b1c1788ac4b0c0a6bab4bd");
  });
  it("decrypt",async function(){
    const encryptionUtilsInstance = await EncryptionUtils.deployed();
    const encrypted = "0x8ac4b2c5b5c06da4aebdc2c1a9b5c1d16599aecab0b1c1788ac4b0c0a6bab4bd";
    const decrypted = await encryptionUtilsInstance.decrypt(encrypted,"ELMX");
    return assert.equal(decrypted,"Exempt Liquidity Market Exchange","expected 'Exempt Liquidity Market Exchange'");
  });
  it("encrypt and emit",async function(){
    const encryptionUtilsInstance = await EncryptionUtils.deployed();
    const tx = await encryptionUtilsInstance.encryptAndEmit("Exempt Liquidity Market Exchange is a private permissioned blockchain","REDEECASH.EXCHANGE");
    return assert.equal(tx.logs[0].event,"Encrypted","expected event Encrypted");
  });
  it("decrypt and emit",async function(){
    const encryptionUtilsInstance = await EncryptionUtils.deployed();
    const tx = await encryptionUtilsInstance.decryptAndEmit("0x97bda9b2b5b7619fb19fbac1a7b1b5c76792b3b7afaab96386cbab96a6c6aaad61b7ba65b365b4b7aeb9a2c7ad4eb5bdb5b5aac1baaec1b3a9a965a5adc2ab99a8c0a4b1af","REDEECASH.EXCHANGE");
    console.log(tx.logs[0].args);
    return assert.equal(tx.logs[0].event,"Decrypted","expected event Decrypted");
  });
});
