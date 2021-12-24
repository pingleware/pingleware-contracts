// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Rule 506(b)
 * -----------
 * https://www.sec.gov/smallbusiness/exemptofferings/
 *
 * Rule 506(b) of Regulation D is considered a “safe harbor” under Section 4(a)(2). It provides objective standards that a company can rely on to meet the requirements
 * of the Section 4(a)(2) exemption. Companies conducting an offering under Rule 506(b) can raise an unlimited amount of money and can sell securities to an
 * unlimited number of accredited investors. An offering under Rule 506(b), however, is subject to the following requirements:
 *
 *  - no general solicitation or advertising to market the securities
 *  - securities may not be sold to more than 35 non-accredited investors (all non-accredited investors, either alone or with a purchaser representative,
 *    must meet the legal standard of having sufficient knowledge and experience in financial and business matters to be capable of evaluating the merits and
 *    risks of the prospective investment)
 *
 * If non-accredited investors are participating in the offering, the company conducting the offering:
 *
 *  - must give any non-accredited investors disclosure documents that generally contain the same type of information as provided in Regulation A offerings
 *    (the company is not required to provide specified disclosure documents to accredited investors, but, if it does provide information to accredited investors,
 *    it must also make this information available to the non-accredited investors as well)
 *  - must give any non-accredited investors financial statement information specified in Rule 506 and
 *  - should be available to answer questions from prospective purchasers who are non-accredited investors
 *
 * Purchasers in a Rule 506(b) offering receive “restricted securities." A company is required to file a notice with the Commission on Form D within 15 days
 * after the first sale of securities in the offering. Although the Securities Act provides a federal preemption from state registration and qualification
 * under Rule 506(b), the states still have authority to require notice filings and collect state fees.
 */
import "../Owned.sol";
import "../Version.sol";
import "../Frozen.sol";
import "../ActiveOffering.sol";
import "../Shares.sol";
import "../Shareholder.sol";
import "../Transaction.sol";
import "../Account.sol";
import "../TransferAgent.sol";

contract ExemptEquityOffering506B is Version, Frozen, TransferAgent {
    uint public constant INITIAL_SUPPLY = 100000 * 1 ether;

    string public constant name = "Rule 506(b) Token";
    string public constant symbol = "TOKEN.506B";
    uint8 public constant decimals = 0;

    uint256 public sharesOustanding = 0;
    uint256 public marketCap        = 0;



    uint256 constant public totalValueMax = 5000000;
    uint constant public maxNonaccredited = 35;
    uint256 private totalValue = 0;


    event Bought(address sender, uint256 value, uint256 epoch);
    event Sold(address sender, uint256 value, uint256 epoch);

    constructor()
        payable
    {
        TransferAgent.setParValue(address(this), 5);
    }


    modifier isMaximumOffering(uint256 amount) {
        require(totalValue + amount < totalValueMax, "maximum offering has been reached");
        _;
    }


    /**
     * As each token is minted it is added to the shareholders array.
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount,bytes32 encrypted, bytes memory signature)
        public
        onlyOwner(encrypted,signature)
        isMinter
        isMaximumOffering(_amount)
        returns (bool)
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Shareholder.isVerifiedAddress(_to),"investor is not verified");
        require(Shares.isPriceBelowParValue(address(this), _amount),"amount is less than par value");
        uint256 _shares = _amount / Shares.getParValue(address(this));
        Transaction.addTransaction(_to, _shares, _amount, block.timestamp);
        return  _mint(_to, _amount, INITIAL_SUPPLY);
    }




    function buy(uint256 amount, uint256 epoch)
        public
        payable
    {
        require(ActiveOffering.isActive(),"offering is not active");
        require(Shareholder.isVerifiedAddress(msg.sender),"investor is not verified");
        require(amount > 0, "You need to send some ether");
        uint256 shares = amount / Shares.getParValue(address(this));
        require(shares <= sharesOustanding, "Not enough shares in the reserve");

        Account.transfer(address(this), msg.sender, amount);
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

        emit Sold(sender,amount,epoch);
    }
}
