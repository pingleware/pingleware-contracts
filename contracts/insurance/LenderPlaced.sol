// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

/**
 * Lender-placed (or Force-placed) insurance is coverage that a mortgage lender or bank purchases for property it owns to protect its interests when
 * the homeowner fails to purchase this coverage.
 */

contract LenderPlace is Version, Owned {

    enum PROPERTY_TYPE {
        PERSONAL,
        REAL
    }
}