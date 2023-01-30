// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Add a freeze or stop when an exception is raised?
 *
 */
import "./Destructible.sol";

contract Frozen is Destructible {
    bool private running = false;

    event Started(address sender,bytes reason);
    event Stopped(address sender,bytes reason);

    function start()
        internal
    {
        running = true;
        emit Started(msg.sender,msg.data);
    }

    function stop()
        internal
    {
        running = false;
        emit Stopped(msg.sender,msg.data);
    }

    function status()
        internal
        view
        returns (bool)
    {
        return running;
    }

    modifier isRunning() {
        require(running, "contract activity is frozen!");
        _;
    }
}