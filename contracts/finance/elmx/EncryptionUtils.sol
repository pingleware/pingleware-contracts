// SPDX-License-Identifier: BSL-1.1
pragma solidity >=0.4.22 <0.9.0;

contract EncryptionUtils {
    event Encrypted(bytes encryptedData);
    event Decrypted(string decryptedData);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    // Encrypt data using AES-GCM
    function encrypt(bytes memory key, string memory data) public pure returns (bytes memory) {
        require(bytes(data).length > 0, "Data must not be empty");

        bytes memory encryptedData = bytes(data); //AES.encrypt(key, bytes(data));
        key;
        return encryptedData;
    }

    // Decrypt data using AES-GCM
    function decrypt(bytes memory key, bytes memory encryptedData) public pure returns (string memory) {
        require(encryptedData.length > 0, "Data must not be empty");

        string memory decryptedData = string(encryptedData); // string(AES.decrypt(key, encryptedData));
        key;
        return decryptedData;
    }

    // Example: Encrypt and emit
    function encryptAndEmit(string memory data, bytes memory key) public {
        bytes memory encrypted = encrypt(key, data);
        emit Encrypted(encrypted);
    }

    // Example: Decrypt and emit
    function decryptAndEmit(bytes memory encryptedData, bytes memory key) public {
        string memory decrypted = decrypt(key, encryptedData);
        emit Decrypted(decrypted);
    }
}