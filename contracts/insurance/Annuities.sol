// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * See example Annuity Contract at https://github.com/MaxHastings/Celery
 */

 /**
  * Florida Law for Annuities: http://www.leg.state.fl.us/STATUTES/index.cfm?App_mode=Display_Statute&Search_String=&URL=0600-0699/0627/Sections/0627.4554.html
  *
  * An Annuity is used to fund an Employee Benefit Plan. Under the Exempt Equity Offerings permits Employee Benefit Plan,
  * creating an annuity to help fund that plan.
  *
  * Annuities are also used to fund tax-exempt deferred compensation plan.
  * Investment instruments for Annuities include: Stocks, Bonds and Currency trding
  */

import "../common/Version.sol";
import "../common/Owned.sol";

contract Annuities is Version, Owned {

    enum ANNUITY_TYPE {
        IMMEDIATE,  // With an immediate annuity, the annuitant pays a single premium and immediately starts receiving payments at the end of each payment period, which is usually monthly or annually
        DEFERRED,   // With a deferred annuity, the annuitant pays one or more premiums over what is often called the accumulation period. The premiums paid and the interest credited to the premiums goes into a fund called an accumulation fund. There may be a minimum guaranteed interest rate at which the money will accumulate during the accumulation period.
        FIXED,      // A fixed annuity provides fixed-dollar income payments backed by the guarantees in the contract. The annuitant cannot lose the investment once the income payments begin. The amount of those payments will not change. With fixed annuities, the company bears the investment risk.
        VARIABLE    // Variable annuity investments are securities, and fluctuate with economic conditions. The value of a variable annuity depends upon the value of the underlying investment portfolios associated with the annuity. The annuitant bears the investment risk for the value of the security. The value of the annuity will increase or decrease with the investment performance of the security.
    }
}