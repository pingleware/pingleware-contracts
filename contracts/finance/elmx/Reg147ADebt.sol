// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

/**
 * Rule 147 is considered a “safe harbor” under Section 3(a)(11), providing objective standards that a company can rely on to meet the requirements of that exemption. 
 * Rule 147, as amended, has the following requirements:
 *
 *     the company must be organized in the state where it offers and sells securities
 *     the company must have its “principal place of business” in-state and satisfy at least one “doing business” requirement that demonstrates the in-state nature of the company’s business
 *     offers and sales of securities can only be made to in-state residents or persons who the company reasonably believes are in-state residents and
 *     the company obtains a written representation from each purchaser providing the residency of that purchaser
 *
 * Securities purchased in an offering under Rule 147 limit resales to persons residing within the state of the offering for a period of six months from the date of the sale by the issuer to the purchaser. 
 * In addition, a company must comply with state securities laws and regulations in the states in which securities are offered or sold.
 */

/**
 * § 230.147 Intrastate offers and sales.
 *
 * (a) This section shall not raise any presumption that the exemption provided by section 3(a)(11) of the Act (15 U.S.C. 77c(a)(11)) is not available for transactions by an issuer which do not satisfy all 
 *     of the provisions of this section. 
 * 
 * (b) Manner of offers and sales.  An issuer, or any person acting on behalf of the issuer, shall be deemed to conduct an offering in compliance with section 3(a)(11) of the Act (15 U.S.C. 77c(a)(11)), where offers and sales are made only to persons resident within the same state or territory in which the issuer is resident and doing business, within the meaning of section 3(a)(11) of the Act, so long as the issuer complies with the provisions of paragraphs (c), (d), and (f) through (h) of this section. 
 * 
 * (c) Nature of the issuer.  The issuer of the securities shall at the time of any offers and sales be a person resident and doing business within the state or territory in which all of the offers and sales are made. 
 * 
 * (1) The issuer shall be deemed to be a resident of the state or territory in which: 
 * 
 * (i) It is incorporated or organized, and it has its principal place of business, if a corporation, limited partnership, trust or other form of business organization that is organized under state or territorial law. The issuer shall be deemed to have its principal place of business in a state or territory in which the officers, partners or managers of the issuer primarily direct, control and coordinate the activities of the issuer; 
 * 
 * (ii) It has its principal place of business, as defined in paragraph (c)(1)(i) of this section, if a general partnership or other form of business organization that is not organized under any state or territorial law; 
 * 
 * (iii) Such person's principal residence is located, if an individual. 
 * 
 * Instruction to paragraph (c)
 * (1):  An issuer that has previously conducted an intrastate offering pursuant to this section (§ 230.147) or Rule 147A (§ 230.147A) may not conduct another intrastate offering pursuant to this section (§ 230.147) in a different state or territory, until the expiration of the time period specified in paragraph (e) of this section (§ 230.147(e)) or paragraph (e) of Rule 147A (§ 230.147A(e)), calculated on the basis of the date of the last sale in such offering. 
 * 
 * (2) The issuer shall be deemed to be doing business within a state or territory if the issuer satisfies at least one of the following requirements: 
 * 
 * (i) The issuer derived at least 80% of its consolidated gross revenues from the operation of a business or of real property located in or from the rendering of services within such state or territory; 
 * 
 * Instruction to paragraph (c)
 *  
 * (2)(i):  Revenues must be calculated based on the issuer's most recent fiscal year, if the first offer of securities pursuant to this section is made during the first six months of the issuer's current fiscal year, and based on the first six months of the issuer's current fiscal year or during the twelve-month fiscal period ending with such six-month period, if the first offer of securities pursuant to this section is made during the last six months of the issuer's current fiscal year. 
 * 
 * (ii) The issuer had at the end of its most recent semi-annual fiscal period prior to an initial offer of securities in any offering or subsequent offering pursuant to this section, at least 80% of its assets and those of its subsidiaries on a consolidated basis located within such state or territory; 
 * 
 * (iii) The issuer intends to use and uses at least 80% of the net proceeds to the issuer from sales made pursuant to this section (§ 230.147) in connection with the operation of a business or of real property, the purchase of real property located in, or the rendering of services within such state or territory; or 
 * 
 * (iv) A majority of the issuer's employees are based in such state or territory. 
 * 
 * (d) Residence of offerees and purchasers.  Offers and sales of securities pursuant to this section (§ 230.147) shall be made only to residents of the state or territory in which the issuer is resident, as determined pursuant to paragraph (c) of this section, or who the issuer reasonably believes, at the time of the offer and sale, are residents of the state or territory in which the issuer is resident. For purposes of determining the residence of offerees and purchasers: 
 * 
 * (1) A corporation, partnership, limited liability company, trust or other form of business organization shall be deemed to be a resident of a state or territory if, at the time of the offer and sale to it, it has its principal place of business, as defined in paragraph (c)(1)(i) of this section, within such state or territory. 
 * 
 * Instruction to paragraph (d)
 * (1):  A trust that is not deemed by the law of the state or territory of its creation to be a separate legal entity is deemed to be a resident of each state or territory in which its trustee is, or trustees are, resident. 
 * 
 * (2) Individuals shall be deemed to be residents of a state or territory if such individuals have, at the time of the offer and sale to them, their principal residence in the state or territory. 
 * 
 * (3) A corporation, partnership, trust or other form of business organization, which is organized for the specific purpose of acquiring securities offered pursuant to this section (§ 230.147), shall not be a resident of a state or territory unless all of the beneficial owners of such organization are residents of such state or territory. 
 * 
 * Instruction to paragraph (d):  Obtaining a written representation from purchasers of in-state residency status will not, without more, be sufficient to establish a reasonable belief that such purchasers are in-state residents. 
 * 
 * (e) Limitation on resales.  For a period of six months from the date of the sale by the issuer of a security pursuant to this section (§ 230.147), any resale of such security shall be made only to persons resident within the state or territory in which the issuer was resident, as determined pursuant to paragraph (c) of this section, at the time of the sale of the security by the issuer. 
 * 
 * Instruction to paragraph (e):  In the case of convertible securities, resales of either the convertible security, or if it is converted, the underlying security, could be made during the period described in paragraph (e) only to persons resident within such state or territory. For purposes of this paragraph (e), a conversion in reliance on section 3(a)(9) of the Act (15 U.S.C. 77c(a)(9)) does not begin a new period. 
 * 
 * (f) Precautions against interstate sales. 
 * 
 * (1) The issuer shall, in connection with any securities sold by it pursuant to this section: 
 * 
 * (i) Place a prominent legend on the certificate or other document evidencing the security stating that: “Offers and sales of these securities were made under an exemption from registration and have not been registered under the Securities Act of 1933. For a period of six months from the date of the sale by the issuer of these securities, any resale of these securities (or the underlying securities in the case of convertible securities) shall be made only to persons resident within the state or territory of [identify the name of the state or territory in which the issuer was resident at the time of the sale of the securities by the issuer].”; 
 * 
 * (ii) Issue stop transfer instructions to the issuer's transfer agent, if any, with respect to the securities, or, if the issuer transfers its own securities, make a notation in the appropriate records of the issuer; and 
 * 
 * (iii) Obtain a written representation from each purchaser as to his or her residence. 
 * 
 * (2) The issuer shall, in connection with the issuance of new certificates for any of the securities that are sold pursuant to this section (§ 230.147) that are presented for transfer during the time period specified in paragraph (e), take the steps required by paragraphs (f)(1)(i) and (ii) of this section. 
 * 
 * (3) The issuer shall, at the time of any offer or sale by it of a security pursuant to this section (§ 230.147), prominently disclose to each offeree in the manner in which any such offer is communicated and to each purchaser of such security in writing a reasonable period of time before the date of sale, the following: “Sales will be made only to residents of [identify the name of the state or territory in which the issuer was resident at the time of the sale of the securities by the issuer]. Offers and sales of these securities are made under an exemption from registration and have not been registered under the Securities Act of 1933. For a period of six months from the date of the sale by the issuer of the securities, any resale of the securities (or the underlying securities in the case of convertible securities) shall be made only to persons resident within the state or territory of [identify the name of the state or territory in which the issuer was resident at the time of the sale of the securities by the issuer].” 
 * 
 * (g) Integration with other offerings.  To determine whether offers and sales should be integrated, refer to § 230.152.
 */

import "./AccessControl.sol";
import "../../interfaces/IPaymentWallet.sol";
import "../../abstract/ADebtToken.sol";

contract Reg147ADebt is ADebtToken, AccessControl {
     constructor() {

    }

    IPaymentWallet paymentWalletContract;

    function setPaymentWalletContract(address paymentWalletAddress) external {
        paymentWalletContract = IPaymentWallet(paymentWalletAddress);
    }


    function validate(address from,address to,uint tokens) external view returns (bool) {
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
        if (tokens == 0) {
            valid--;
        }
        if (valid == 0) {
            return true;
        }
        return false;
    }
    function transfer(address from,address to, uint tokens)  external returns (bool) {
        require(from == msg.sender,"not from msg.sender");
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        paymentWalletContract.transfer(to, tokens, paymentWalletContract.getCVV());
        return true;
    }
    function transferFrom(address from, address to, uint tokens)  external returns (bool) {
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        paymentWalletContract.transferFrom(from, to, tokens, "N/A");
        return true;
    }
    function getBalanceFrom(address wallet) external view returns (uint256) {
        require(address(paymentWalletContract) != address(0x0),"PaymentWallet contract is not set");
        return paymentWalletContract.getBalance(wallet);
    }
    function getTradingStatus() external view returns (bool) {
        return TRADING_ACTIVE;
    }

    function buy(address wallet,uint256 tokens,uint256 Fee) external {

    }

    function getIssuer() external view returns (address) {
        return issuer;
    }
    function getOutstandingShares() external view returns (uint256) {
        return OUTSTANDING_SHARES;
    }
    function getTotalSupply() external view returns (uint256) {

    }
    function getOfferingType() external view returns (string memory) {
        return offeringType;
    }
}