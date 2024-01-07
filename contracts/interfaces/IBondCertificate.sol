// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IBondCertificate {
    function setMemberPoolContract(address poolAddress) external;
    function createCertificate(address tokenAddress,address wallet, string memory _bondName, uint256 _bondAmount, uint256 _maturityDate) external;
    function transferCertificate(address tokenAddress,address from, uint _certificateNumber, address _to, uint256 _amount) external;
    function getCertificateBalance(address tokenAddress, uint256 _certificateId) external view returns (uint256);
    function getCertificatesByOwner(address _owner) external view returns (uint[] memory);
    function getCertificateByNumber(address tokenAddress,uint _certificateNumber) external view returns (uint certificateNumber,address owner,string memory bondName,uint256 bondAmount,uint256 maturityDate);
    function redeemBond(address token, address wallet, uint _certificateNumber) external;
}