// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

contract LongTermCare is Version, Owned {

    /**
     * Typical eligibility for the payment of benefits shall not be more restrictive than requiring a deficiency in the ability to perform not more than three of the
     * activities of daily living.
     */
    enum DAILY_LIVING_ACTIVITY {
        BATHING,        // (a) “Bathing,” which means washing oneself by sponge bath or in either a tub or shower, including the task of getting into or out of the tub or shower.
        CONTINENCE,     // (b) “Continence,” which means the ability to maintain control of bowel and bladder function, or, when unable to maintain control of bowel or bladder function, the ability to perform associated personal hygiene, including caring for catheter or colostomy bag.
        DRESSING,       // (c) “Dressing,” which means putting on and taking off all items of clothing and any necessary braces, fasteners, or artificial limbs.
        EATING,         // (d) “Eating,” which means feeding oneself by getting food into the body from a receptacle, such as a plate, cup, or table, or by a feeding tube or intravenously.
        TOILETING,      // (e) “Toileting,” which means getting to and from the toilet, getting on and off the toilet, and performing associated personal hygiene.
        TRANSFERRING    // (f) “Transferring,” which means moving into or out of a bed, chair, or wheelchair.
    }

    enum LEVEL_OF_ASSISTANCE {
        MINIMAL,
        MODERATE,
        MAXIMAL
    }

}