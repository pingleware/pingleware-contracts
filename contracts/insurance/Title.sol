// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../Version.sol";
import "../Owned.sol";

/**
 * Title Insurance Contract
 * See http://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0600-0699/0627/0627PartXIIIContentsIndex.html&StatuteYear=2016&Title=-%3E2016-%3EChapter%20627-%3EPart%
 */

contract Title is Version, Owned {

    struct Owner {
        address property_owner;
        uint256 beginning;
        uint256 ending;
    }

    struct TitleSearch {
        address property;
        Owner[] owners;
    }
}