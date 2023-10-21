// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

//import "./AccessControl.sol";

contract BondCertificate {
    // Structure to represent bond certificates
    struct BondCertificateMeta {
        uint certificateNumber;
        address owner;
        string bondName;
        uint256 bondAmount;
        uint256 maturityDate;
    }

    // Mapping from certificate number to Certificate struct
    mapping(address => mapping(uint => BondCertificateMeta)) private certificates;

    // Mapping from owner address to an array of certificate numbers they own
    mapping(address => uint[]) public ownerCertificates;

    // Events to log certificate creation and transfer
    event BondCertificateCreated(uint certificateNumber, address owner, string bondName);
    event BondCertificateTransferred(uint certificateNumber, address from, address to);
    event BondRedeemed(uint _certificateNumber, address from);

    // Counter for generating unique certificate numbers
    uint private certificateCounter = 1;


    // Function to create a new bond certificate
    function createCertificate(address tokenAddress,address wallet, string memory _bondName, uint256 _bondAmount, uint256 _maturityDate) external  {
        uint certificateNumber = certificateCounter++;
        certificates[tokenAddress][certificateNumber] = BondCertificateMeta(certificateNumber, wallet, _bondName, _bondAmount, _maturityDate);
        ownerCertificates[wallet].push(certificateNumber);
        emit BondCertificateCreated(certificateNumber, wallet, _bondName);
    }

    // Function to transfer a bond certificate to another address
    function transferCertificate(address tokenAddress,address from, uint _certificateNumber, address _to, uint256 _amount) external  {
        require(from == certificates[tokenAddress][_certificateNumber].owner, "You do not own this certificate");
        
        // Update the balances of the sender and recipient
        certificates[tokenAddress][_certificateNumber].bondAmount -= _amount;
        certificates[tokenAddress][_certificateNumber].owner = _to;

        ownerCertificates[_to].push(_certificateNumber);
        
        emit BondCertificateTransferred(_certificateNumber, from, _to);
    }

     // Function to check the balance of a specific certificate
    function getCertificateBalance(address tokenAddress, uint256 _certificateId) external view  returns (uint256) {
        return certificates[tokenAddress][_certificateId].bondAmount;
    }

    // Function to retrieve bond certificates owned by a wallet
    function getCertificatesByOwner(address _owner) external view   returns (uint[] memory) {
        return ownerCertificates[_owner];
    }

    // Function to retrieve a bond certificate by certificate number
    function getCertificateByNumber(address tokenAddress,uint _certificateNumber) external view  returns (
        uint certificateNumber,
        address owner,
        string memory bondName,
        uint256 bondAmount,
        uint256 maturityDate
    ) {
        BondCertificateMeta storage certificate = certificates[tokenAddress][_certificateNumber];
        require(certificate.owner != address(0), "Certificate does not exist");
        
        return (
            certificate.certificateNumber,
            certificate.owner,
            certificate.bondName,
            certificate.bondAmount,
            certificate.maturityDate
        );
    }

    // Function to redeem a bond when it reaches maturity
    function redeemBond(address tokenAddress,address wallet, uint _certificateNumber) external  {
        BondCertificateMeta storage certificate = certificates[tokenAddress][_certificateNumber];
        require(certificate.owner == wallet, "You do not own this certificate");
        require(block.timestamp >= certificate.maturityDate, "Bond has not yet reached maturity");

        // Update certificate ownership
        certificate.owner = address(0);
        removeItem(wallet,_certificateNumber);

        emit BondRedeemed(_certificateNumber, wallet);
    }

    // Helper function to remove an item from an array
    function removeItem(address wallet, uint _certificateNumber) internal {
        uint[] storage certificateNumbers = ownerCertificates[wallet];
        for (uint i = 0; i < certificateNumbers.length; i++) {
            if (certificateNumbers[i] == _certificateNumber) {
                certificateNumbers[i] = certificateNumbers[certificateNumbers.length - 1];
                certificateNumbers.pop();
                break;
            }
        }
    }
}
