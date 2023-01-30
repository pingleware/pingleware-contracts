// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";

contract AccidentHealth is Version, Frozen {
    enum HEALTH_MANAGED_PLANS {
        HMO,    // Health Maintenance Organizations (HMOs)
        EPO,    // Exclusive Provider Organizations (EPOs)
        PPO,    // Preferred Provider Organizations (PPOs)
        POS     //Point-of-Service Plans.
    }

    enum HEALTH_PLAN_COVERAGE {
        BASIC_MEDICAL,      // Basic medical coverage
        MAJOR_MEDICAL,      // Major medical coverage
        BASIC_HOSPITAL,     // basic hospital expense
        BASIC_SURGICAL,     // basic surgical expense
        DISEASE_SPECIFIC,   // specified diseases
        HOSPITAL_INDEMNITY  // hospital indemnity plans
    }

    enum REGULATORY_FORMS {
        A1,	// Property & Casualty Financial Oversight
        A2,	// Life & Health Financial Oversight
        A3,	// Specialty Product Review
        B1,	// Property & Casualty Product Review
        B2,	// Life & Health Product Review
        B3,	// Market Investigations
        C1,	// Applications Coordination
        D0 	// Forms with cross-unit usage
    }

    enum HEALTH_CHECKLIST {
        OIR_B2_520, // Individual Health Application Checklist
        OIR_B2_521, // Individual Health Outline of Coverage Checklist
        OIR_B2_523, // Individual Health Contract Checklist
        OIR_B2_524, // Out_of_State Group Health Checklist
        OIR_B2_525, // Group Health Application Checklist
        OIR_B2_526, // Group Health Contract Checklist
        OIR_B2_527, // Debtor Group Application Checklist
        OIR_B2_528, // Additional Information Checklist/Debtor Group
        OIR_B2_529, // Debtor Group Contract Checklist
        OIR_B2_535, // Blanket Health Contracts Checklist
        OIR_B2_536, // Franchise Health Application Checklist
        OIR_B2_537, // Franchise Health Outline of Coverage Checklist
        OIR_B2_538, // Franchise Health Contract Checklist
        OIR_B2_539, // Excess_Specific and Aggregate Checklist
        OIR_B2_540, // Informational Memorandum Checklist _ Excess Specific and Aggregate
        OIR_B2_541, // Group/Individual Long Term Care Application Checklist
        OIR_B2_542, // Group/Individual Long Term Care Outline of Coverage Checklist
        OIR_B2_543, // Group/Individual Long Term Care Contract Checklist
        OIR_B2_1354, // Medicare Supplement Application Checklist
        OIR_B2_1355, // Medicare Supplement Contract Checklist
        OIR_B2_1353, // Pre_Paid Limited Benefit Contract Checklist
        OIR_B2_1360, // Pre_Paid Limited Benefit Ind. Application Checklist
        OIR_B2_1359, // Pre_Paid Limited Benefit Conversion Application Checklist
        OIR_B2_1358, // Pre_Paid Limited Benefit Group Application Checklist
        OIR_B2_1357, // Florida Small Group Health Checklist For Indemnity Plans Other Than Standard and Basic
        OIR_B2_1356, // Florida HMO Contract Checklist
        OIR_B2_1607, // Discount Medical Plan Organization (DMPO) Contract and Application Checklist
        OIR_B2_1616, // Blanket Application Checklist
        OIR_B2_1617, // Florida HMO Individual Application Checklist
        OIR_B2_1618, // Florida HMO Master Group Application Checklist
        OIR_B2_1619, // Long Term Care Advertisement Checklist
        OIR_B2_1620, // Medicare Supplement Advertisement Checklist
        OIR_B2_162, //1 Medicare Supplement Outline of Coverage Checklist
        OIR_B2_1622, // Small Group Advertisement Checklist
        OIR_B2_1623, // Health Flex Plan Checklist
        OIR_B2_1650 // Residency Contract Checklist (CCRC)
    }

}