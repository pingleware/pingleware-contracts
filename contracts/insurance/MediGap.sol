// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

contract MediGap is Version, Owned {

    enum FORM {
        OIR_B2_MSR,     // Medicare Supplement Refund Calculation Form
        OIR_B2_MSB,     //__ Reporting Forms for the Calculation of Benchmark Loss Ratio since Inception
        OIR_B2_1354,    // Medicare Supplement Application Checklist
        OIR_B2_1355,    // Medicare Supplement Contract Checklist
        OIR_B2_1620,    // Medicare Supplement Advertisement Checklist
        OIR_B2_1621,    // Medicare Supplement Outline of Coverage Checklist
        OIR_B2_MSC2    // Medicare Supplement Revised (MACRA) Outline of Coverage
    }
}