// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract WorkersCompensation is Version, Owned {
    enum COVERAGE {
        MEDICAL,
        DISABILITY,
        DEATH
    }
}