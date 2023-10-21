// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../libs/ecverify.sol";
import "./ReentrancyGuard.sol";

contract Owned {
    uint256 constant public WAIT = 30 seconds;

    address private owner;

    uint256 private previous_block_timestamp = 0;

    mapping(uint256 => bool) private usedNonces;

    event FallbackEvent(address sender, uint256 amount);
    event ReceiveEvent(address sender, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        previous_block_timestamp = block.timestamp;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier rateLimitCheck() {
        require (block.timestamp > previous_block_timestamp + WAIT, "rate limit error");
        _;
    }

    /**
     * Solving the onlyOwner sppofing:
     * using web3.eth.sign() to generate a signed hash of the owner address and passing the hash and signature to this method
     *
     */
    modifier onlyOwner() {
        require (msg.sender == owner, "access denied for owner"); // WARNING: this can be spoofed!
        _;
    }

    modifier isOwner(address addr) {
        require (addr == owner, "owner access denied for user"); // WARNING: this can be spoofed!
        _;
    }

    modifier okOwner() {
        require(msg.sender == owner,"unauthorized, not the owner");
        _;
    }

    function getOwner()
        public
        payable
        rateLimitCheck
        returns (address)
    {
        require (block.timestamp > previous_block_timestamp + WAIT, "rate limit error");
        previous_block_timestamp = block.timestamp;
        return owner;
    }

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

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public payable virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}