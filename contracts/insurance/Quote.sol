// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

// Migrate to solidity https://github.com/geetotes/acme-insurance-quotes

contract Quote is Version, Owned {

    enum States {
        WELCOME,
        VEHICLE_CHOOSE,
        CAR,
        BOAT,
        BOAT_DETAIL,
        CONFIRM
    }

    enum INSURANCE_TYPES {
        ACCIDENT_HEALTH,        // Accident and Health
        ANNUITIES,              // Annuities
        AUTOMOBILE,             // Automobile
        FLOOD_INSURANCE,        // Flood Insurance
        HOMEOWNERS,             // Homeowners'
        LIFE,                   // Life
        LONG_TERM_CARE,         // Long-Term Care
        MEDICARE_SUPPLEMENT,    // Medicare Supplement
        PROFESSIONAL_LIABILITY, // Professional Liability
        TITLE,                  // Title
        VEHICLE_SERVICE,        // Warranties and Motor Vehicle Service Agreements
        WORKERS_COMPENSATION    //Workers' Compensation        
    }

    
}