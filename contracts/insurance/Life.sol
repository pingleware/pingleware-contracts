// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract Life is Version, Owned {

    enum INSURANCE_TYPE {
        TERM,       // which provides insurance for a specified period of time at a lower cost
        PERMANENT   // which provides a certain amount of coverage at variable rates.
    }

    struct Insurance {
        INSURANCE_TYPE _type;
        bool           _universal;
    }
}