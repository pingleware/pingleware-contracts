// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Intrastate:Section 3(a)(11)
 * ---------------------------
 * See https://www.sec.gov/smallbusiness/exemptofferings/intrastateofferings
 *
 * Section 3(a)(11) of the Securities Act is generally known as the
 * “intrastate offering exemption.” This exemption seeks to facilitate the financing of
 * local business operations. To qualify for the intrastate offering exemption,
 * a company must:
 *
 *   - be organized in the state where it is offering the securities
 *   - carry out a significant amount of its business in that state and
 *   - make offers and sales only to residents of that state
 *   - resales have a holding period of six months from purchase
 *
 * The intrastate offering exemption does not limit the size of the offering or the number
 * of purchasers. A company must determine the residence of each offeree and purchaser.
 * If any of the securities are offered or sold to even one out-of-state person,
 * the exemption may be lost. Without the exemption, the company would be in violation
 * of the Securities Act if the offering does not qualify for another exemption.
 */

import "../Owned.sol";
import "../Version.sol";
import "../Frozen.sol";
import "../Account.sol";
import "../Shareholder.sol";
import "../Transaction.sol";
import "../TransferAgent.sol";

contract ExemptEquityOffering3A11 is Version, Frozen, TransferAgent {
    string public constant name = "Rule 3(a)(11) Token";
    string public constant symbol = "TOKEN.3A11";
    uint8 public constant decimals = 0;

    uint256 public sharesOustanding = 0;
    uint256 public marketCap        = 0;

    uint256 private parValue = 0;
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
        require(ActiveOffering.isActive(), "offering is not active");
        require(Shareholder.isVerifiedAddress(msg.sender), "investor is not verified");
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
        require(Shareholder.isVerifiedAddress(sender),"investor is not verifies");
        require(Transaction.isHoldingPeriodOver(sender),"holding period has not expired");
        require(amount > 0, "You need to sell at least some tokens");
        uint256 __allowance = allowance(sender, address(this));
        require(__allowance >= amount, "Check the token allowance");
        transferFrom(sender, address(this), amount, epoch);

        emit Sold(sender,amount,epoch);
    }
}
