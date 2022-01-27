// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

contract Automobile is Version, Owned {

    enum VEHICLE_TYPE {
        PASSENGER,  // passenger type automobiles
        PICKUPS,    // pickups
        VAN,        // vans
        TRUCK,      // trucks
        MOTORCYCLE  // motorcycles
    }

    enum AUTO_INSURANCE_PERSONAL_TYPE {
        NO_FAULT,           // Private Passenger Auto No-Fault (Personal Injury Protection or PIP)
        LIABIITY,           // Private Passenger Auto Liability (Liability of the insured for Bodily Injury or Property Damage inflicted and other coverages not involving damage to the vehicle itself)
        PHYSICAL_DAMAGE     // Private Passenger Auto Physical Damage (Comprehensive, Collision, and miscellaneous other coverages involving damage to the vehicle itself)
    }

    enum AUTO_INSURANCE_COMMERCIAL_TYPE {
        LIABILITY,          // Commercial Automobile Liability (Liability of the insured for Bodily Injury or Property Damage inflicted, Medical Payments, other coverages not involving damage to the vehicle itself)
        PHYSICAL_DAMAGE     // Commercial Auto Physical Damage (Comprehensive, Collision, and miscellaneous other coverages involving damage to the vehicle itself)
    }
}