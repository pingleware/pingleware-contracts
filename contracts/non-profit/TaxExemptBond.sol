// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";

contract TaxExemptBond is Version, Frozen {

string public issuerName;
    address public issuerAddress;
    uint256 public principalAmount;
    uint256 public couponRate;
    uint256 public maturityDate;
    uint256 public issuanceDate;
    address public bondHolder;
    bool public isRedeemed;
    uint256 public redemptionDate;

    event BondIssued(
        string issuerName,
        address issuerAddress,
        uint256 principalAmount,
        uint256 couponRate,
        uint256 maturityDate,
        uint256 issuanceDate,
        address bondHolder
    );

    event BondRedeemed(address bondHolder, uint256 redemptionDate);

    constructor(
        string memory _issuerName,
        address _issuerAddress,
        uint256 _principalAmount,
        uint256 _couponRate,
        uint256 _maturityDate,
        uint256 _issuanceDate,
        address _bondHolder
    ) {
        issuerName = _issuerName;
        issuerAddress = _issuerAddress;
        principalAmount = _principalAmount;
        couponRate = _couponRate;
        maturityDate = _maturityDate;
        issuanceDate = _issuanceDate;
        bondHolder = _bondHolder;
        isRedeemed = false;
        redemptionDate = 0;

        emit BondIssued(
            _issuerName,
            _issuerAddress,
            _principalAmount,
            _couponRate,
            _maturityDate,
            _issuanceDate,
            _bondHolder
        );
    }

    function redeemBond() public {
        require(msg.sender == bondHolder, "Only the bond holder can redeem the bond.");
        require(block.timestamp >= maturityDate, "The bond has not matured yet.");
        require(!isRedeemed, "The bond has already been redeemed.");

        isRedeemed = true;
        redemptionDate = block.timestamp;

        emit BondRedeemed(bondHolder, redemptionDate);
    }
}