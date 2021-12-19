// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Regulation A: Tier 2
 * --------------------
 * See https://www.investor.gov/introduction-investing/investing-basics/glossary/regulation
 *
 * Under Tier 2, an issuer can raise up to $50 million in any 12-month period, including no more than $15 million on behalf of selling securityholders that are
 * affiliates of the issuer.  Unlike Tier 1 offerings, the offering statement does not have to be qualified by a state securities regulator, and the issuer is subject to
 * ongoing reporting requirements in the form of an annual report on Form 1-K, a semiannual report on Form 1-SA and a current report on Form 1-U.
 */

import "./ExemptEquityOfferingRegA.sol";

contract ExemptEquityOfferingAT2 is ExemptEquityOfferingRegA {
  constructor()
  {
    name = "Regulation A Tier 2 Token";
    symbol = "TOKEN.AT2";
    owner = msg.sender;
    addMinter(owner);
    totalValueMax = 50000000;
  }
}
