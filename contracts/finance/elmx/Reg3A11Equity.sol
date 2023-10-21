// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * See https://www.sec.gov/education/smallbusiness/exemptofferings/intrastateofferings
 *
 * Intrastate Exempt Offerings under Section 3(a)(11) of the Act (15 U.S.C. 77c(a)(11))
 * 
 * Section 3(a)(11) of the Securities Act is generally known as the “intrastate offering exemption.” 
 * This exemption seeks to facilitate the financing of local business operations. To qualify for the intrastate offering exemption, a company must: 
 *     be organized in the state where it is offering the securities
 *     carry out a significant amount of its business in that state and
 *     make offers and sales only to residents of that state
 *
 * The intrastate offering exemption does not limit the size of the offering or the number of purchasers. A company must determine the residence of each offeree and purchaser. 
 * If any of the securities are offered or sold to even one out-of-state person, the exemption may be lost. 
 * Without the exemption, the company would be in violation of the Securities Act if the offering does not qualify for another exemption.
 *
 * Review https://thebusinessprofessor.com/en_US/business-transactions/what-is-a-section-3a-securities-registration-exemption
 * What are the Benefits of Section 3 Exemptions? 
 *
 * The exemption is attractive to issuers because it allows for: an unlimited number of investors, an unlimited amount of raised capital, 
 * and general solicitation of investors may be allowed under the applicable state law.
 *
 * A Section 3(a)(11) offering is generally considered a public offering. Securities acquired in such an offering are not "restricted" under Rule 144(a)(3).
 * See https://www.sec.gov/interps/telephone/cftelinterps_securitesactsections.pdf
 *
 * Important Interpretations for Section 3(a)(11) [A38-45]
 * 38. Section 3(a)(11)
 *      The intrastate offering exemption is not rendered unavailable solely because the proceeds of the offering will be temporarily invested 
 *      in out-of-state CD's.
 * 39. Section 3(a)(11)
 *      An issuer makes an offering of securities in reliance upon the Section 3(a)(11) exemption and permits purchasers to pay for their securities 
 *      in installments. The question was raised whether such purchasers must satisfy the residency requirement of Section 3(a)(11) until the 
 *      completion of their installment payments. The Division staff expressed the view that if an installment payment represented a separate 
 *      investment decision, the purchaser must be a resident at the time of that payment. On the other hand, if a purchaser was unconditionally 
 *      committed by such purchaser's initial decision to purchase the securities, such purchaser need not remain a resident during the installment 
 *      period.
 * 40. Section 3(a)(11)
 *      A Section 3(a)(11) offering is generally considered a public offering. Securities acquired in such an offering are not "restricted" under Rule 144(a)(3).
 * 41. Section 3(a)(11)
 *      An exchange offer would not be exempt pursuant to Section 3(a)(11) where it is necessary to make the offer to some joint holders of stock of the subject company who are non-residents of the state where the offeror is domiciled.
 * 42. Section 3(a)(11)
 *      A new corporation would not be precluded from relying on Section 3(a)(11) for an offering simply because a significant part of its business would be interstate mail order.
 * 43. Section 3(a)(11)
 *      A new bank holding company was being formed to hold the securities of two banks. It was intended to issue stock to acquire the securities of one bank in an intrastate offering under Section 3(a)(11), while simultaneously issuing stock to acquire the second bank pursuant to a registered exchange offer. Under the five-factor test of Release No. 33-4552, the two offerings would be integrated. Thus, the Section 3(a)(11) exemption would not be available due to its limitation to intrastate offerings.
 * 44. Section 3(a)(11)
 *      A purchaser in an offering exempt from registration under Section 3(a)(11) intends to transfer the securities purchased to the purchaser's Individual Retirement Account less than nine months after the offering. The IRA is administered by an out-of-state trustee. The residence of the trustee would not affect the availability of the intrastate exemption for the initial offering.
 * 45. Section 3(a)(11); Section 4(2)
 *      Sales of stock to promoters pursuant to Section 4(2) generally are not integrated with a subsequent intrastate offering exempt from 
 *      registration pursuant to Section 3(a)(11).
 * 
 */

 /**
  * NOT A RESTRICTED SECURITY
  *
  * A Section 3(a)(11) offering is generally considered a public offering. Securities acquired in such an offering are not "restricted" under Rule 144(a)(3)
  */

/**
 * Form U-1 is used to notifiy the SEC and the State of this exempt offering
 */

 /**
  * See https://www.sec.gov/education/smallbusiness/exemptofferings/intrastateofferings
  * 
  * Section 3(a)(11) of the Securities Act is generally known as the “intrastate offering exemption.” This exemption seeks to facilitate the financing of local business operations. 
  * To qualify for the intrastate offering exemption, a company must:
  *
  *  - be organized in the state where it is offering the securities
  *  - carry out a significant amount of its business in that state and
  *  - make offers and sales only to residents of that state
  *
  * The intrastate offering exemption does not limit the size of the offering or the number of purchasers. A company must determine the residence of each offeree and purchaser. 
  * If any of the securities are offered or sold to even one out-of-state person, the exemption may be lost. Without the exemption, the company would be in violation of the Securities Act if the offering 
  * does not qualify for another exemption.
  */

import "../../interfaces/IPaymentWallet.sol";
import "../../abstract/AEquityToken.sol";

contract Reg3A11Equity is AEquityToken {
    string public homeJurisdiction;
    uint256 public bid = 0;
    uint256 public ask = 0;

    uint256 lastCertificateAssigned = 0;

    address public issuer;

    event ValueTransferred(address, uint256);
    event Approval(address,address,uint256);
    event Disapproval(address indexed investor, uint tokens, string reason);
    event Request(address investor,uint tokens,bool buy);

    constructor(address tokenIssuer,string memory jurisdiction,string memory tokenName,string memory tokenSymbol,uint256 tokenSupply,uint256 tokenPrice) {
        issuer = tokenIssuer;

        homeJurisdiction = jurisdiction;
        name = tokenName;
        symbol = tokenSymbol;
        totalSupply = tokenSupply;
        price = tokenPrice;

        MAX_OFFERING_SHARES = tokenSupply; // a maximum offering is set, to permit immediate resales after the funding round has been complete.
    }

    function validate(address from,address to,uint tokens) public view returns (bool) {
        int valid = 0;
        if (TRANSFERS_ACTIVE == false) {
            valid--;
        }
        if (from == address(0x0)) {
            valid--;
        }
        if (to == address(0x0)) {
            valid--;
        }
        if (tokens > totalSupply) {
            valid--;
        }
        if (valid == 0) {
            return true;
        }
        return false;
    }

    function transfer(address from,address to, uint tokens)  external returns (bool) {
        IPaymentWallet paymentWallet = IPaymentWallet(from);
        paymentWallet.transfer(to,tokens,paymentWallet.getCVV());
        return true;
    }
    function transferFrom(address from, address to, uint tokens)  external returns (bool) {
        IPaymentWallet paymentWallet = IPaymentWallet(from);
        paymentWallet.transferFrom(to, tokens, "N/A");
        return true;
    }
    function getBalanceFrom(address wallet) external view returns (uint256) {
        IPaymentWallet paymentWallet = IPaymentWallet(wallet);
        return paymentWallet.getBalance();
    }
    function getIssuer() external view returns (address) {
        return issuer;
    }

     function buy(address wallet,uint256 tokens,uint256 fee) external {
        IPaymentWallet paymentWallet = IPaymentWallet(wallet);
        uint256 amount = SafeMath.safeMul(tokens,price);
        paymentWallet.transfer(issuer, amount, paymentWallet.getCVV());
        fee;
     }
}