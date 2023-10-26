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

function encrypt(string memory content, string memory passcode) public pure returns (bytes memory) {
        bytes memory contentBytes = bytes(content);
        bytes memory passcodeBytes = bytes(passcode);

        bytes memory result = new bytes(contentBytes.length);

        for (uint256 i = 0; i < contentBytes.length; i++) {
            uint8 contentChar = uint8(contentBytes[i]);
            uint8 passcodeChar = uint8(passcodeBytes[i % passcodeBytes.length]);
            uint8 encryptedChar = contentChar + passcodeChar;
            result[i] = bytes1(encryptedChar);
        }

        return result;
    }

    function decrypt(bytes memory content, string memory passcode) public pure returns (string memory) {
        bytes memory passcodeBytes = bytes(passcode);
        bytes memory resultBytes = new bytes(content.length);

        for (uint256 i = 0; i < content.length; i++) {
            uint8 encryptedChar = uint8(content[i]);
            uint8 passcodeChar = uint8(passcodeBytes[i % passcodeBytes.length]);
            uint8 decryptedChar = encryptedChar - passcodeChar;
            resultBytes[i] = bytes1(decryptedChar);
        }

        string memory result = string(resultBytes);
        return result;
    }

    // Example: Encrypt and emit
    function encryptAndEmit(string memory data, string memory key) public {
        bytes memory _encrypted = encrypt(data, key);
        emit Encrypted(_encrypted);
    }

    // Example: Decrypt and emit
    function decryptAndEmit(bytes memory encryptedData, string memory key) public {
        string memory decrypted = decrypt(encryptedData, key);
        emit Decrypted(decrypted);
    }
}