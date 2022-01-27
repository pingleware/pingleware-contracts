// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;




import "../../Version.sol";
import "../../Owned.sol";
import "../Offering.sol";
import "../../Frozen.sol";
import "../../Account.sol";
import "../Shareholder.sol";
import "../Transaction.sol";
import "../TransferAgent.sol";

contract ExemptEquityOffering is Version, Owned, Offering, TransferAgent {



    modifier notIPO(OfferingType _type) {
        require(_type != OfferingType.S1, "An IPO or public offering is NOT permitted for exempt offering!");
        _;
    }

    constructor(string memory name, string memory symbol, uint256 maxShares, OfferingType offeringType)
        notIPO(offeringType)
    {
        setOffering(address(this),name,symbol,maxShares,offeringType);
    }

    function getContractAddress()
        public
        view
        returns (address)
    {
        return address(this);
    }




}