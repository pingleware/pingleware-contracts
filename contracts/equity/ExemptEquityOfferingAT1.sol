// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Regulation A: Tier 1
 * --------------------
 * See https://www.investor.gov/introduction-investing/investing-basics/glossary/regulation
 *
 * Under Tier 1, an issuer can raise up to $20 million in any 12-month period, including no more than $6 million on behalf of selling security holders that are
 * affiliates of the issuer.  In addition to qualification by SEC staff, companies offering securities pursuant to Tier 1 of Regulation A will also need to file
 * and have their offering statements qualified by the state securities regulators in the states in which the issuer plans to sell its securities.
 * Companies offering securities under Tier 1 do not have ongoing reporting requirements other than a final report on Form 1-Z on the status of the offering.
 */

import "./ExemptEquityOfferingRegA.sol";

contract ExemptEquityOfferingAT1 is ExemptEquityOfferingRegA {

  constructor()
  {
    name = "Regulation A Tier 1 Token";
    symbol = "TOKEN.AT1";
    owner = msg.sender;
    addMinter(owner);
    totalValueMax = 20000000;
  }
}
