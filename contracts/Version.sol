// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

abstract contract Version {
    struct VersionStorage {
        string version;
    }

    string public VERSION = getVersion();

    function versionStorage()
        internal
        pure
        returns (VersionStorage storage ds)
    {
        bytes32 position = keccak256("version.storage");
        assembly { ds.slot := position }
    }

    function getVersion()
        internal
        view
        returns (string memory)
    {
        return versionStorage().version;
    }

    constructor() {
        versionStorage().version = "1.0.8";
    }
}