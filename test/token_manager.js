const TokenManager = artifacts.require("TokenManager");
const Reg3A11Equity = artifacts.require("Reg3A11Equity");
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/TokenManager", function (accounts) {
  it("should assert true", async function () {
    await TokenManager.deployed();
    return assert.isTrue(true);
  });
  it("assign token", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tx = await tokenManagerInstance.assignToken(Reg3A11Equity.address,"0x50542cF0903152E1761cffF01d2928C6F229D678","PRESSPAGE ENTERTAINMENT INC Reg 3(a)(11) Interstate Offering","PRESS.3A11X",1000000,"Regulation 3(a)(11) Interstate");
    return assert.equal(tx.logs[0].event,"AssignedOffering","expected event AssignedOffering");
  });
  it("update token name", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tx = await tokenManagerInstance.updateTokenName("PRESS.3A11X","PRESSPAGE ENTERTAINMENT INC - Regulation 3(a)(11)");
    return assert.equal(tx.logs[0].args[1],"PRESSPAGE ENTERTAINMENT INC - Regulation 3(a)(11)","expected 'PRESSPAGE ENTERTAINMENT INC - Regulation 3(a)(11)'");
  });
  it("update token address", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tx = await tokenManagerInstance.updateTokenAddress("PRESS.3A11X",Reg3A11Equity.address);
    return assert.equal(tx.logs[0].args[1],Reg3A11Equity.address,`expected token address of ${Reg3A11Equity.address}`);
  });
  it("update token offering type", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tx = await tokenManagerInstance.updateTokenOfferingType("PRESS.3A11X","REG3A11");
    return assert.equal(tx.logs[0].args[1],"REG3A11","expected offering regulation of REG3A11");
  });
  it("get token", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tokenAddress = await tokenManagerInstance.getToken("PRESS.3A11X");
    return assert.equal(tokenAddress,Reg3A11Equity.address,`expected token address of ${Reg3A11Equity.address}`);
  });
  it("get token regulation", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tokenRegulation = await tokenManagerInstance.getTokenRegulation("PRESS.3A11X");
    return assert.equal(tokenRegulation,"REG3A11","expected regulation type of REG3A11");
  });
  it("remove token", async function () {
    const tokenManagerInstance = await TokenManager.deployed();
    const tx = await tokenManagerInstance.removeToken("PRESS.3A11X");
    return assert.equal(tx.logs[0].event,"DelistedToken","expected event DelistedToken");
  });
});
