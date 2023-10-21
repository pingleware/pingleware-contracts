// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * S-1 Offering:
 * Corporate Finance Reporting Manual at https://www.sec.gov/page/corpfin-section-landing
 *
 * Useful for an issuer who wishes to conduct a Direct Public Offering or DPO on the blockchain after their S-1 has been quallified.
 * The filing fee for an S-1 is at https://www.sec.gov/ofm/Article/feeamt.html
 * Currently is $92.70 per $1,000,000
 * If you have a PAR value of $5 per share, then the minimum authorized shares would be 200,000 shares.
 * Liquidity is most important in a public offering!
 */

import "./BaseOffering.sol";

abstract contract IOfferingS1 is BaseOffering {
    string public constant DESCRIPTION = string("Public Offering under S-1");
    bool public constant RESTRICTED_SECURITY = false;

    string public CUSIP = string("TO BE ASSIGNED");
    string public SEC_FILENUMBER = string("001-00000");
    uint256 public MAX_OFFERING = 0;
    uint256 public MAX_OFFERING_SHARES = 0; // based on the maximum allowance offering and intial share price

    function getMaxOffering() virtual public view returns(uint256);
    function transfer(address to, uint tokens) virtual override public returns (bool success);
    function transferFrom(address from, address to, uint tokens) virtual override public returns (bool success);
    function mint(uint256 _amount) virtual public returns (bool);
    function burn(uint256 _amount) virtual public returns (bool);
    function setCUSIP(string memory cusip) virtual override public;
    function setSECFilenumber(string memory fileNumber) virtual override public;
    function setMaxOffering(uint256 value) virtual override public;
    function setMaxShares(uint256 value) virtual override public;
}