const PaymentWallet = artifacts.require("PaymentWallet");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/PaymentWallet", function (accounts) {
  it("should assert true", async function () {
    await PaymentWallet.deployed();
    return assert.isTrue(true);
  });
  it("add a wallet", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    await paymentWalletInstance.addWallet(accounts[1],100,0,0);
    return assert.isTrue(true);
  });
  it("set expiration date", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const today = new Date();
    const currentMonth = Number(today.getMonth() + 1);
    const futureYear = Number(today.getFullYear() % 100) + 10; // set future year to five years
    const mmyy = `${currentMonth}${futureYear}`; // set the expiration MMYY to a future date
    const currentYear = new Date().getFullYear(); // dependent on the future implementation of javascript to return the increase number of digits for the full year.
    const yearDigits = currentYear.toString().length;
    const century = Number(currentYear.toString().substring(0,Number(yearDigits - 2)) + "00");
    const month = Math.floor(mmyy / 100);
    const year = mmyy % 100 + century;

    const targetDate = new Date(`${month}/1/${year}`);   
    const timestamp = targetDate.getTime() / 1000;

    await paymentWalletInstance.setExpiration(accounts[1],BigInt(timestamp));
    const expiration = await paymentWalletInstance.getExpirationDate(accounts[1]);
    return assert.equal(expiration.toNumber(),timestamp,`expected ${timestamp}`);
  });
  it("update expiration date", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const today = new Date();
    const currentMonth = Number(today.getMonth() + 1);
    const futureYear = Number(today.getFullYear() % 100) + 5; // set future year to five years
    const mmyy = `${currentMonth}${futureYear}`; // set the expiration MMYY to a future date
    const currentYear = new Date().getFullYear(); // dependent on the future implementation of javascript to return the increase number of digits for the full year.
    const yearDigits = currentYear.toString().length;
    const century = Number(currentYear.toString().substring(0,Number(yearDigits - 2)) + "00");
    const month = Math.floor(mmyy / 100);
    const year = mmyy % 100 + century;

    const targetDate = new Date(`${month}/1/${year}`);   
    const timestamp = targetDate.getTime() / 1000;
    await paymentWalletInstance.updateExpirationDate(accounts[1],BigInt(timestamp));
    await paymentWalletInstance.updateExpirationDate(accounts[2],BigInt(timestamp)); // set expiration for a second account sued in transfer/transferFrom
    await paymentWalletInstance.updateExpirationDate(accounts[3],BigInt(timestamp)); // set expiration for a second account sued in transfer/transferFrom
    const expiration = await paymentWalletInstance.getExpirationDate(accounts[1]);
    return assert.equal(expiration.toNumber(),timestamp,`expected ${timestamp}`);
  });
  it("get expiration date", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const expiration = await paymentWalletInstance.getExpirationDate(accounts[1]);
    return assert.isTrue(expiration.toNumber() > 0);
  });
  it("set cvc code", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    await paymentWalletInstance.setCVVCode(accounts[1],555);
    const cvcCode = await paymentWalletInstance.getCVV({from: accounts[1]});
    console.log(cvcCode.toNumber());
    return assert.isTrue(true);
  });
  it("update cvv code", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    await paymentWalletInstance.updatedCVV(accounts[1],323);
    const cvcCode = await paymentWalletInstance.getCVV({from: accounts[1]});
    console.log(cvcCode.toNumber());
    return assert.isTrue(true);
  });
  it("get cvc code", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const cvcCode = await paymentWalletInstance.getCVV({from: accounts[1]});
    console.log(cvcCode.toNumber());
    return assert.isTrue(true);
  });
  it("verify cvc code", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const status = await paymentWalletInstance.verifyCVV(accounts[1],323);
    return assert.isTrue(status);
  });
  it("deposit", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const tx = await paymentWalletInstance.deposit(accounts[1],1000);
    console.log(tx.logs[0].args[2].toNumber());
    const amount = tx.logs[0].args[2].toNumber();
    return assert.equal(amount,1000,"expected a deposit of $1,000");
  });
  it("withdraw", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const tx = await paymentWalletInstance.withdraw(100,{from: accounts[1]});
    return assert.equal(tx.logs[0].args[0].toNumber(),100,"expected a withdrawal of $1,000");
  });
  it("transfer amount to another wallet", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    await paymentWalletInstance.transfer(accounts[2],350,323,{from: accounts[1]});
    //console.log(tx);
    //console.log(tx.logs[0].args);
    return assert.isTrue(true);
  });
  it("transfer between wallets", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    await paymentWalletInstance.transferFrom(accounts[1],accounts[3],500,"testing");
    return assert.isTrue(true);
  });
  it("get balance", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const balance = await paymentWalletInstance.getBalance(accounts[1]);
    console.log(balance.toNumber());
    return assert.isTrue(true);
  });
  it("is expired wallet for non-expired wallet", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    const today = new Date();
    const currentMonth = Number(today.getMonth() + 1);
    const futureYear = Number(today.getFullYear() % 100) + 5; // set future year to five years
    const mmyy = `${currentMonth}${futureYear}`; // set the expiration MMYY to a future date
    const currentYear = new Date().getFullYear(); // dependent on the future implementation of javascript to return the increase number of digits for the full year.
    const yearDigits = currentYear.toString().length;
    const century = Number(currentYear.toString().substring(0,Number(yearDigits - 2)) + "00");
    const month = Math.floor(mmyy / 100);
    const year = mmyy % 100 + century;

    const targetDate = new Date(`${month}/1/${year}`);   
    const timestamp = targetDate.getTime() / 1000;

    await paymentWalletInstance.updateExpirationDate(accounts[1],BigInt(timestamp));
    const expired = await paymentWalletInstance.isExpired(accounts[1]);
    return assert.equal(expired,false,"expected to false, not expired");
  });
  it("is expired wallet for an expired wallet", async function () {
    const paymentWalletInstance = await PaymentWallet.deployed();
    /**
     * The Year 10,000 problem (also known as the Y10K problem, Y10K Bug, and Y10K) 
     * is an error machines and computers will encounter when they need to express five digits for a year.
     * 
     * This fix will handle Y10K and beyond by getting the year prefix and replacing the two year digit with double zero.
     */
    /**
     * If this code is still being used after 10,000 years, thank you for helping my code achieve immortality!
     * 
     * Patrick O. Ingle 
     * 10/28/2023
     * 
     * "A true forward thinker"
     */
    // convert MMYY to an epoch timestamp
    const mmyy = 122; // set the expiration MMYY to a past date
    const currentYear = new Date().getFullYear(); // dependent on the future implementation of javascript to return the increase number of digits for the full year.
    const yearDigits = currentYear.toString().length;
    const century = Number(currentYear.toString().substring(0,Number(yearDigits - 2)) + "00");
    const month = Math.floor(mmyy / 100);
    const year = mmyy % 100 + century;

    const targetDate = new Date(`${month}/1/${year}`);    
    const timestamp = targetDate.getTime() / 1000;

    // update the expiration date with the expired timestamp
    await paymentWalletInstance.updateExpirationDate(accounts[1],BigInt(timestamp));
    const expiration = await paymentWalletInstance.getExpirationDate(accounts[1]);

    assert.equal(expiration.toNumber(),timestamp,`expected ${timestamp}`);
    // verify wallet has expired
    const expired = await paymentWalletInstance.isExpired(accounts[1],);
    return assert.isTrue(expired);
  });
});
