// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Add a freeze or stop when an exception is raised?
 *
 */

abstract contract Frozen {
    bool private running = false;

    function start()
        internal
    {
        running = true;
    }

    function stop()
        internal
    {
        running = false;
    }

    modifier isRunning() {
        require(running, "contract activity is frozen!");
        _;
    }
}