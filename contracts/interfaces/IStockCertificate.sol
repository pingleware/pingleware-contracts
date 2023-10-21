// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

interface IStockCertificate {
    function setMemberPoolContract(address poolAddress) external;
    function issueCertificate(address tokenAddress, string calldata symbol, address _investor, uint256 _initialBalance) external returns(uint256);
    function transferCertificate(address from, address tokenAddress, uint256 _certificateId, address _to, uint256 _amount) external;
    function getCertificateBalance(address tokenAddress, uint256 _certificateId) external view returns (uint256);
    function getInvestorCertificates(address _investor) external view returns (uint256[] memory);
    function isCertificateValid(address tokenAddress,address wallet,uint256 _certificateId) external view returns (bool);
}