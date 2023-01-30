// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract Homeowners is Version, Owned {

    enum COMPONENT {
        STRUCTURE,          // Coverage A: Structure (the dwelling itself)
        OTHER_STRUCTURES,   // Coverage B: Other structures (sheds and fences)
        PERSONAL_PROPERTY,  // Coverage C: Personal property (contents of the structures)
        LOSS_OF_USE,        // Coverage D: Loss of use (Additional Living Expense or ALE)
        PERSONAL_LIABILITY, // Coverage L: Personal Liability
        MEDICAL_PAYMENTS    // Coverage M: Medical Payments to Others
    }

    enum POLICY {
        BASIC,          // HO-1 — Basic Form
        BROAD,          // HO-2 — Broad Form
        SPECIAL,        // HO-3 — Special Form
        COMPREHENSIVE,  // HO-5 — Comprehensive Form
        OLDER_HOME,     // HO-8 — Older Home Form
        TENANT,         // HO-4 Tenant
        CONDO,          // HO-6 — Condo Form
        MOBILE_HOME     // HO-7 — Mobile Home Form
    }

}