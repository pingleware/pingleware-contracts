// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * A foreign exchange swap or currency swap is a contract under which two parties agree to exchange two currencies at a set rate and then to re-exchange those currencies
 * at an agreed upon rate at a fixed date in the future.
 *
 *
 * https://github.com/alanwhite1203/fxSwap
 */


contract Swap {
    event FallbackEvent(address sender, uint256 amount);
    event ReceiveEvent(address sender, uint256 amount);

    // @notice Will receive any eth sent to the contract
    // https://ethereum.stackexchange.com/questions/42995/how-to-send-ether-to-a-contract-in-truffle-test
    // https://www.codegrepper.com/code-examples/whatever/Expected+a+state+variable+declaration.+If+you+intended+this+as+a+fallback+function+or+a+function+to+handle+plain+ether+transactions%2C+use+the+%22fallback%22+keyword+or+the+%22receive%22+keyword+instead.
    fallback()
        external
        payable
    {
        require(tx.origin == msg.sender, "phishing attack detected?");
        emit FallbackEvent(msg.sender,msg.value);
    }

    receive()
        external
        payable
    {
        emit ReceiveEvent(msg.sender,msg.value);
    }

}