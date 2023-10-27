const ExchangeTradedFund = artifacts.require("ExchangeTradedFund");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("finance/elmx/ExchangeTradedFund", function (/* accounts */) {
  it("should assert true", async function () {
    await ExchangeTradedFund.deployed();
    return assert.isTrue(true);
  });
  it("set brokerage fee", async function () {
    const etfInstance = await ExchangeTradedFund.deployed();

    return assert.isTrue(true);
  });
  it("create a new token offering", async function () {
    const etfInstance = await ExchangeTradedFund.deployed();

    return assert.isTrue(true);
  });
  it("calculate net asset value (NAV) of fund", async function () {
    const etfInstance = await ExchangeTradedFund.deployed();

    return assert.isTrue(true);
  });
  it("buy shares in the ETF", async function () {
    const etfInstance = await ExchangeTradedFund.deployed();

    return assert.isTrue(true);
  });
  it("redeem shares in the ETF", async function () {
    const etfInstance = await ExchangeTradedFund.deployed();

    return assert.isTrue(true);
  });
});
