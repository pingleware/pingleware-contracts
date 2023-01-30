// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;
import "../../libs/SafeMath.sol";
import "../../common/Frozen.sol";
import "../credit/Credit.sol";

contract PeerToPeerLending is Frozen {
    /** @dev Usings */
    // Using SafeMath for our calculations with uints.
    using SafeMath for uint;

    /** @dev State variables */

    // User structure
    struct User {
        // Is the user currently credited.
        bool credited;

        // The adress of the active credit.
        Credit activeCredit;

        // Is the user marked as fraudlent.
        bool fraudStatus;

        // All user credits.
        Credit[] allCredits;
    }

    // We store all users in a mapping.
    mapping(address => User) public users;

    // Array of all credits adresses.
    Credit[] public credits;

    /** @dev Events */
    event LogCreditCreated(address indexed _address, address indexed _borrower, uint indexed timestamp);
    event LogCreditStateChanged(address indexed _address, Credit.State indexed state, uint indexed timestamp);
    event LogCreditActiveChanged(address indexed _address, bool indexed active, uint indexed timestamp);
    event LogUserSetFraud(address indexed _address, bool fraudStatus, uint timestamp);

    /** @dev Constructor */
    constructor() {

    }

    /**
      * @dev Credit application function.
      *
      * The function publishesh another contract which is the credit contract.
      * The owner of the new contract is the present contract.
      *
      * @param requestedAmount Requested funding amount in wei.
      * @param repaymentsCount Requested repayments count.
      * @param creditDescription The description of the funding.
      * returns credit Return credit address.
      */

    function applyForCredit(uint requestedAmount, uint repaymentsCount, uint interest, bytes32 creditDescription) public returns(Credit _credit) {
        // The user should not have been credited;
        require(users[msg.sender].credited == false);

        // THe user should not be marked as fraudlent.
        require(users[msg.sender].fraudStatus == false);

        // Assert there is no active credit for the user.
        assert(address(users[msg.sender].activeCredit) == address(0));

        // Mark the user as credited. Prevent from reentrancy.
        users[msg.sender].credited = true;

        // Create a new credit contract with the given parameters.
        Credit credit = new Credit(requestedAmount, repaymentsCount, interest, creditDescription);

        // Set the user's active credit contract.
        users[msg.sender].activeCredit = credit;

        // Add the credit contract to our list with contracts.
        credits.push(credit);

        // Add the credit to the user's profile.
        users[msg.sender].allCredits.push(credit);

        // Log the credit creation event.
        emit LogCreditCreated(address(credit), msg.sender, block.timestamp);

        // Return the address of the newly created credit contract.
        return credit;
    }

    /** @dev Get the list with all credits.
      * returns credits Returns list of credit addresses.
      */
    function getCredits() public view returns (Credit[] memory) {
        return credits;
    }

    /** @dev Get all users credits.
      * returns users[msg.sender].allCredits Return user credits.
      */
    function getUserCredits() public view returns (Credit[] memory) {
        return users[msg.sender].allCredits;
    }

    /** @dev Sets user fraudlent status true.
     * @param _borrower The user's address.
     * returns users[_borrower].fraudStatus Boolean of the new fraud status.
     */
    function setFraudStatus(address _borrower) external returns (bool) {
        // Update user fraud status.
        users[_borrower].fraudStatus = true;

        // Log fraud status.
        emit LogUserSetFraud(_borrower, users[_borrower].fraudStatus, block.timestamp);

        return users[_borrower].fraudStatus;
    }

    /** @dev Function to switch active state of a credit.
      * @param _credit The credit's address.
      * @param state New state.
      */
    function changeCreditState (Credit _credit, Credit.State state) public okOwner {
        // Call credit contract changeStage.
        Credit credit = Credit(_credit);
        credit.changeState(state);

        // Log state change.
        emit LogCreditStateChanged(address(credit), state, block.timestamp);
    }

    /** @dev Function to toggle active state of credit contract.
      * @param _credit The credit's address.
      */
    function changeCreditState (Credit _credit) public okOwner {
        // Call credit contract toggleActive method.
        Credit credit = Credit(_credit);
        bool active = credit.toggleActive();

        // Log state change.
        emit LogCreditActiveChanged(address(credit), active, block.timestamp);
    }
}
