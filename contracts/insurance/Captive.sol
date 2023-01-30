// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Owned.sol";

/**
 * Florida Law for Captive Insurance Company at http://www.leg.state.fl.us/Statutes/index.cfm?App_mode=Display_Statute&URL=0600-0699/0628/0628PartVContentsIndex.html&StatuteYear=2016&Title=-%3E2016-%3EChapter%20628-%3EPart%20V
 *
 * A captive insurance company, if permitted by its charter or articles of incorporation, may apply to the office for a license to do any and all insurance authorized
 * under the insurance code, other than workers’ compensation and employer’s liability, life, health, personal motor vehicle, and personal residential property insurance
 * with excptions. See statues for these exceptions?
 */

contract Captive is Version, Owned {

    enum CAPTIVE_CLASSIFICATION {
        PURE,               // Pure Captive Insurance Company – a company that insures risks of its parent, affiliated companies, controlled unaffiliated businesses,
                            //   or a combination thereof.
        INDUSTRIAL,         // Industrial Insured Captive Insurance Company – a captive insurance company that provides insurance only to the industrial insureds that
                            //   are its stockholders or members, and affiliates thereof, or to the stockholders, and affiliates thereof, of its parent corporation.
                            //   They can also provide reinsurance to insurers only on risks written by such insurers for the industrial insureds that are the stockholders
                            //   or members, and affiliates thereof, of the industrial insured captive insurer, or the stockholders, and affiliates thereof,
                            //   of the parent corporation of the industrial insured captive insurer.
        SPECIAL_PURPOSE     // Special Purpose Captive Insurance Company – a captive insurance company that is formed or licensed under Chapter 628, F.S.
                            //   that does not meet the definition of any other type of captive insurance company defined in Part V, Chapter 628.
                            //   A special purpose captive insurance company may insure only the risk of its parent under S. 628.905, F.S.
    }
}