// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

/**
 * For use in writing Flood Insurance policies, see more at https://www.floir.com/Sections/PandC/FloodInsurance/FloodInsuranceForInsurers.aspx
 *
 * Federal Emergency Management Agency (FEMA) Flood Manual: https://www.fema.gov/flood-insurance-manual
 *
 * NFIP Policies: https://www.fema.gov/national-flood-insurance-program/standard-flood-insurance-policy-forms
 *
 */

contract FloodInsurance is Version, Owned {

    enum FLOOD_INSURANCE_TYPE {
        PRIMARY,
        EXCESS
    }

    enum FLOOD_COVERAGE {
        STANDARD,       // Standard flood insurance;
        PREFERRED,      // Preferred flood insurance;
        CUSTOMIZED,     // Customized flood insurance;
        FLEXIBLE,       // Flexible flood insurance; and
        SUPPLEMENTAL    // Supplemental flood insurance
    }

}