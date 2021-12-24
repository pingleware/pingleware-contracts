// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Rule 506(c)
 * -----------
 * See https://www.sec.gov/smallbusiness/exemptofferings/rule506c
 *
 * Rule 506(c) permits issuers to broadly solicit and generally advertise an offering, provided that:
 *
 *  - all purchasers in the offering are accredited investors
 *  - the issuer takes reasonable steps to verify purchasers’ accredited investor status and
 *  - certain other conditions in Regulation D are satisfied
 *
 * Purchasers in a Rule 506(c) offering receive “restricted securities.” A company is required to file a notice with the Commission on Form D within 15 days
 * after the first sale of securities in the offering. Although the Securities Act provides a federal preemption from state registration and qualification under
 * Rule 506(c), the states still have authority to require notice filings and collect state fees.
 */
 
import "../Owned.sol";
import "../Version.sol";
import "../Frozen.sol";
import "../Account.sol";
import "../Shareholder.sol";
import "../TransferAgent.sol";

contract ExemptEquityOffering506C is Version, Frozen, TransferAgent {

    uint public constant INITIAL_SUPPLY = 100000;

    string public name      = "Rule 506(c) Token";
    string public symbol    = "TOKEN.506C";
    
    uint8  public constant decimals = 0;
    
    uint256 public sharesOustanding = 0;
    uint256 public marketCap        = 0;

    uint256 private parValue = 0;

    uint private year = 52 weeks;

    event Bought(address sender, uint256 value, uint256 epoch);
    event Sold(address sender, uint256 value, uint256 epoch);

    constructor()
        payable
    {
        TransferAgent.setParValue(address(this), parValue);
    }


    function balanceOf(address addr)
      public
      payable
      returns (uint256)
    {
      return Account.balanceOf(addr);
    }

    function buy(uint256 amount, uint256 epoch)
        public
        payable
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Shareholder.isVerifiedAddress(msg.sender),"investor is not verified");
        require(amount > 0, "You need to send some ether");
        require(amount <= sharesOustanding, "Not enough shares in the reserve");

        transfer(msg.sender, amount, epoch);
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
        uint256 __allowance = allowance(msg.sender, address(this));
        require(__allowance >= amount, "Check the token allowance");
        transferFrom(sender, address(this), amount, epoch);

        emit Sold(sender,amount,epoch);
    }

}
