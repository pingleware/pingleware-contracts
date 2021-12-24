// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Employee benefit plans – Rule 701
 * See https://www.sec.gov/smallbusiness/exemptofferings/rule701
 *
 * Rule 701 exempts certain sales of securities made to compensate employees, consultants and advisors.
 * This exemption is not available to Exchange Act reporting companies. A company can sell at least $1 million of securities under this exemption,
 * regardless of its size. A company can sell even more if it satisfies certain formulas based on its assets or on the number of its outstanding securities.
 * If a company sells more than $10 million in securities in a 12-month period, it is required to provide certain financial and other disclosure to the persons
 * that received securities in that period. Securities issued under Rule 701 are “restricted securities” and may not be freely traded unless the securities
 * are registered or the holders can rely on an exemption
 */

import "../Owned.sol";
import "../Version.sol";
import "../Frozen.sol";
import "../Account.sol";
import "../ActiveOffering.sol";
import "../Transaction.sol";
import "../Shareholder.sol";
import "../Shares.sol";
import "../TransferAgent.sol";

contract ExemptEquityOffering701 is Version, Frozen, TransferAgent {
    uint256 constant public INITIAL_SUPPLY = 1000000;
    string public constant name = "Rule 701 Token";
    string public constant symbol = "TOKEN.701";
    uint8 public constant decimals = 0;

    uint256 public sharesOustanding = 0;
    uint256 public marketCap        = 0;

    uint constant public parValue = 0.00125 ether;
    uint constant public totalValueMax = 1000000 * parValue;
    uint256 private annual_limit = 0;
    uint256 private start_annual_limit_period;
    uint private totalValue = 0;

    uint256 private contract_creation; // The contract creation time

    bool private restricted = true;

    uint private year = 52 weeks;
    uint private sixmonths = 26 weeks;

    event Bought(address sender, uint256 value, uint256 epoch);
    event Sold(address sender, uint256 value, uint256 epoch);

    constructor()
        payable
    {
        contract_creation = block.timestamp;
        start_annual_limit_period = contract_creation;
        TransferAgent.setParValue(address(this), parValue);
    }


    modifier isPriceBelowParValue(uint amount) {
      require(amount > parValue, "amount is below par value");
      _;
    }

    modifier isRestrictedSecurity() {
      require(restricted != false, "security is restricted");
      _;
    }

    modifier soldGreaterTenMillionperYear() {
        require (annual_limit <= 2.5 ether,"exceeded $10,000,000 within 12 months, reporting is required");
        _;
    }

    modifier isReachedTwelveMonths() {
        if (block.timestamp > (start_annual_limit_period + 52 weeks)) {
            start_annual_limit_period = block.timestamp;
        }
        _;
    }

    function balanceOf(address addr)
      public
      payable
      returns (uint256)
    {
      return Account.getBalance(addr);
    }


    /**
     * As each token is minted it is added to the shareholders array.
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
        public
        soldGreaterTenMillionperYear
        isReachedTwelveMonths
        onlyTransferAgent
        isMinter
        returns (bool)
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Shareholder.isVerifiedAddress(_to),"investor is not verified");
        // if the address does not already own share then
        // add the address to the shareholders array and record the index.
        Shareholder.updateShareholders(_to);
        uint256 _shares = _amount / Shares.getParValue(address(this));
        Transaction.addTransaction(_to, _shares, _amount, block.timestamp);

        return _mint(_to, _amount, INITIAL_SUPPLY);
    }


    function buy(uint256 amount, uint256 epoch)
        public
        payable
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Shareholder.isVerifiedAddress(msg.sender),"investor is not verified");
        require(amount > 0, "You need to send some ether");
        require(amount <= sharesOustanding, "Not enough shares in the reserve");

        Account.transfer(address(this), msg.sender, amount);
        uint256 shares = amount / Shares.getParValue(address(this));
        Transaction.addTransaction(msg.sender, shares, amount, epoch);
        emit Bought(msg.sender,amount,epoch);
    }


    function sell(address payable sender,uint256 amount,uint256 epoch)
        public
        payable
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Shareholder.isVerifiedAddress(sender),"investor is not verified");
        require(Transaction.isHoldingPeriodOver(sender),"holding period has not expired");
        require(amount > 0, "You need to sell at least some tokens");
        uint256 __allowance = allowance(sender, address(this));
        require(__allowance >= amount, "Check the token allowance");
        Account.transfer(sender, address(this), amount);
        uint256 shares = amount / Shares.getParValue(address(this));
        Transaction.addTransaction(sender, shares, amount, epoch);
        emit Sold(sender,amount,epoch);
    }
}
