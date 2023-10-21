# Smart Contract Audits

The following smart contracts were audit using ChatGPT as an initial audit.

## Classified

The provided Solidity smart contract is named "Classifieds." It appears to be a contract for managing classified ads and trading items using ERC20 and ERC721 tokens. Below is a breakdown of the key features and functions of this contract:

1. SPDX License Identifier: The SPDX-License-Identifier comment at the beginning of the code specifies the license under which the code is released. In this case, it's using the Creative Commons Attribution 4.0 International License (CC-BY-4.0).
2. Pragma Directive: This specifies the version of the Solidity compiler that should be used for compiling the contract. It allows versions greater than or equal to 0.4.22 and less than 0.9.0.
3. Imports: The contract imports two interfaces: "IERC20" and "IERC721." These are likely the interfaces for ERC20 and ERC721 tokens. These interfaces are used to interact with the tokens.
4. Struct: The contract defines a struct named "Trade" to store information about a trade, including the poster's address, item ID, description, price, and status. The status can be "Open," "Executed," or "Cancelled."
5. State Variables:

   - `currencyToken`: An instance of an ERC20 token interface (likely representing the currency used for trading).
   - `itemToken`: An instance of an ERC721 token interface (likely representing the items being traded).
   - `trades`: A mapping that associates a trade ID (an unsigned integer) with a "Trade" struct.
   - `tradeCounter`: An unsigned integer used to keep track of the number of trades.
6. Events:

   - The contract defines an event named "TradeStatusChange" to log changes in the status of a trade.
7. `getTrade` Function:

   - This function allows users to retrieve the details of a trade by providing its ID.
   - It returns the poster's address, item ID, description, price, and status.
8. `openTrade` Function:

   - This function is used to open a new trade, placing the specified item in escrow.
   - It transfers the item from the sender (msg.sender) to the contract.
   - It creates a new "Trade" struct and stores it in the "trades" mapping with the status set to "Open."
   - The "tradeCounter" is incremented, and an event is emitted to indicate that a new trade has been opened.
9. `executeTrade` Function:

   - This function allows a user to execute a trade.
   - It checks that the trade status is "Open" and transfers the specified currency from the sender to the poster.
   - It also transfers ownership of the item to the trade filler and updates the trade status to "Executed."
10. `cancelTrade` Function:

- This function is used by the poster to cancel an open trade.
- It transfers the item back to the poster and updates the trade status to "Cancelled."

It's important to note that the contract relies on the ERC20 and ERC721 token interfaces for interacting with tokens. The exact behavior of this contract depends on how the token contracts are implemented and integrated with this contract. Additionally, ensure that the contract's functionality aligns with its intended purpose and that it is thoroughly tested for security and correctness before deploying it on the Ethereum blockchain.

## Inventory

## Pawn

## RetailInstallmentSales

## Store

The provided Solidity smart contract is named "Store." It appears to be a retail store contract that allows registered customers to interact with the store by managing their shopping carts and purchasing products. Below is a breakdown of the key features and functions of this contract:

1. SPDX License Identifier: The SPDX-License-Identifier comment at the beginning of the code specifies the license under which the code is released, which is the Creative Commons Attribution 4.0 International License (CC-BY-4.0).
2. Pragma Directive: This specifies the version of the Solidity compiler that should be used for compiling the contract. It allows versions greater than or equal to 0.4.22 and less than 0.9.0.
3. Imports: The contract imports two other Solidity files, "Version.sol" and "Owned.sol." These likely contain common utilities used in this contract.
4. State Variables:

   - `store_name`: A bytes32 variable representing the name of the store.
   - `store_balance`: A uint256 variable representing the store's balance.
   - `customers`: A mapping of customer addresses to Customer struct instances.
   - `products`: A mapping of product IDs to Product struct instances.
5. Events: The contract defines numerous events for various actions, including customer registration, product registration, cart updates, and more. These events are used to log important activities on the contract.
6. Structs:

   - `Cart`: Represents a customer's shopping cart, containing an array of product IDs and a sum of product prices.
   - `Customer`: Represents a customer with an address, name, balance, and a shopping cart.
   - `Product`: Represents a product with an ID, name, description, price, and default amount.
   - `Receipt` and `InvoiceLine` are defined but not used in the contract.
7. Constructor: Initializes the store's name and balance when the contract is deployed.
8. Functions:

   - The contract provides various functions for registering and deregistering products and customers, inserting and removing products from a customer's cart, checking out the cart, emptying the cart, and renaming the store.
   - Some functions require a digital signature to be called, and they are protected by the `onlyOwner` modifier, indicating that only the owner of the contract can execute these functions.
   - The functions related to cart management and checkout involve updating customer balances and store balances based on the actions taken.
9. Getters:

   - Several functions are provided to retrieve information from the contract, such as product details, cart contents, customer balances, and the store's balance.
10. Helper Function: `checkProductValidity` is a private function used to validate product information. It checks if the product price is greater than 0.

It's important to note that the contract is designed to be a simplified retail store, and it may need further development and testing to be fully functional. Additionally, the behavior of the contract depends on the implementation details of the "Version" and "Owned" contracts, which are not provided here. Careful consideration and testing are needed before deploying this contract on the Ethereum blockchain.

## TicketSales

The provided Solidity smart contract is named "TicketSales." It represents a system for selling and managing event tickets, including the purchase of tickets, checking in attendees, and various administrative functions. Below is a breakdown of the key features and functions of this contract:

1. SPDX License Identifier: The SPDX-License-Identifier comment at the beginning of the code specifies the license under which the code is released, which is the Creative Commons Attribution 4.0 International License (CC-BY-4.0).
2. Pragma Directive: This specifies the version of the Solidity compiler that should be used for compiling the contract. It allows versions greater than or equal to 0.4.22 and less than 0.9.0.
3. State Variables:

   - `owner`: The address of the owner of the contract.
   - `totalTickets`: The total number of tickets available for the event.
   - `showTime`: The timestamp of the event's show time.
   - `checkInDeadline`: The timestamp representing the check-in deadline, set 30 minutes before the show time.
   - `ticketsPurchased`: A mapping that associates addresses with arrays of Ticket structs, representing tickets purchased by each address.
   - `isOpen`: A boolean indicating whether ticket sales are open.
4. Events: The contract defines several events to log various activities, including ticket purchases, check-ins, and ticket resales.
5. Structs:

   - `Ticket`: Represents an individual ticket with information such as the section, row, seat, price, and flags for whether the ticket is sold or checked in.
6. Constructor: Initializes the contract with the owner's address and the show time, setting ticket sales to be open by default.
7. Modifiers:

   - `onlyOwner`: A modifier that ensures only the contract owner can execute certain functions.
   - `salesOpen`: A modifier that checks whether ticket sales are open before allowing certain actions.
   - `checkInOpen`: A modifier that checks whether check-in is open before allowing attendee check-ins.
8. Functions:

   - The contract provides several functions for managing the ticket sales system.
   - The owner can set the check-in deadline, add tickets to different sections with prices, close ticket sales, and withdraw funds.
   - Attendees can purchase tickets, check in at the event, and check their purchased tickets.
   - The `withdrawFunds` function allows the owner to withdraw the contract's balance.
9. The `purchaseTicket` Function:

   - Attendees can purchase a ticket by specifying the section, row, and seat.
   - The function verifies the availability of the selected ticket and transfers the ticket price to the owner.
   - The purchased ticket is then added to the attendee's list of purchased tickets.
   - The selected ticket is marked as "sold," and its reference is removed from the available tickets.
10. The `checkIn` Function:

- Attendees can check in at the event by specifying the section, row, and seat of their ticket.
- The function marks the selected ticket as "checked in."

11. The `closeTicketSales` Function:

- The owner can close ticket sales, preventing further ticket purchases.

12. The `withdrawFunds` Function:

- The owner can withdraw the contract's balance, which includes the proceeds from ticket sales.

13. Getters: The contract provides functions to query the contract's balance, get purchased tickets for a specific address, and get the purchased tickets for the caller.

It's important to note that the contract provides a basic ticket sales system, but it should be used as a starting point and might require further development and security auditing before being deployed for real-world use. The behavior of the contract is also influenced by the owner's actions, and it assumes that the owner operates the system in good faith.
