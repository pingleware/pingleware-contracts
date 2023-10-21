# Smart Contract Audits

The following smart contracts were audit using ChatGPT as an initial audit.

## AAccessControl

The code you've provided is an abstract contract in Solidity, a programming language for developing smart contracts on the Ethereum blockchain. This abstract contract is named `AAccessControl` and inherits from the interface contract `IAccessControl`. It appears to implement basic access control mechanisms.

Here's a breakdown of the key components and functions in this contract:

1. **State Variables**:

   - `address private owner`: This variable stores the Ethereum address of the contract owner, who has certain privileges within the contract.
   - `bool private reentrantGuard`: This variable is used to prevent reentrant calls, a common security issue in smart contracts.
2. **Events**:

   - `event Sender(address _sender)`: This is an event that can be emitted to log the address of the sender.
3. **Constructor**:

   - The constructor is executed when the contract is deployed. It sets the `owner` variable to the address of the contract creator (i.e., the deployer of the contract).
4. **Modifiers**:

   - `isOwner`: A modifier that checks if the sender of a function call is the owner of the contract. If not, it throws an error.
   - `isContract(address _contract)`: A modifier that checks if the provided address matches the contract's address. If not, it throws an error. This is a way to restrict certain functions to be called only within the contract.
   - `nonReentrant`: A modifier used to prevent reentrant calls. If the `reentrantGuard` is already set to `true`, it throws an error. It sets the `reentrantGuard` to `true` at the beginning of the function, then sets it back to `false` after the function execution.
5. **Function**:

   - `getOwner()`: A public function that allows anyone to query the owner's address. It is marked as `view`, meaning it doesn't modify the state and can be called without incurring gas costs.

Please note that this is an abstract contract, and it's meant to be extended by other contracts that implement specific access control logic. This contract provides a foundation for access control and reentrancy protection, and additional functionality can be built upon it in derived contracts.

When you extend this abstract contract with additional functionality, you can use the provided modifiers and access control checks to ensure that only authorized users can perform certain actions within your smart contract.

## ADebtToken

The provided Solidity abstract contract, `ADebtToken`, appears to represent a debt token for a corporate bond. It inherits from two other interfaces, `IAccessControl` and `IDebtToken`, suggesting that it implements certain access control and debt-related functionality. Below is an analysis of the key components and functions in this contract:

**State Variables**:

1. `uint256 constant public SIXMONTHS`: This is a public constant variable set to 180 days, representing six months.
2. `uint256 constant public YEAR`: This is a public constant variable set to 365 days, representing one year.
3. `bool public TRANSFERS_ACTIVE`: A public boolean variable that indicates whether transfers are currently active. It's initially set to `false`.
4. `bool public TRADING_ACTIVE`: A public boolean variable that indicates whether trading is currently active. It's also initially set to `false`.
5. `string public name`: This variable stores the name of the corporate bond.
6. `address public issuer`: This variable stores the address of the bond issuer.
7. `uint256 public bondPrincipal`: It stores the principal amount of the bond.
8. `uint256 public bondCouponRate`: This variable stores the annual coupon rate in basis points (1/100th of a percentage).
9. `uint256 public bondMaturityDate`: It stores the Unix timestamp of the bond's maturity date.
10. `uint256 public bondRating`: This variable represents the bond rating of the issuer, possibly on a scale of 1 to 10.
11. `BondHolder[] public bondHolders`: This is an array that appears to store information about bond holders. It's declared but not defined in the provided code snippet.

**Functions**:

1. `getMarketValue()`: This public function calculates the market value of the bond based on its coupon rate, principal, and maturity date. It uses a loop to calculate the present value of future cash flows (coupon payments) and then adds the face value at maturity. The result is the market value of the bond.
2. `getMarketWeight(uint256 totalExchangeMarketValue)`: This external function calculates the market weight of this bond relative to the total market value of bonds on an exchange. It likely returns a percentage weight, indicating the proportion of the total exchange market value that this bond represents.
3. `calculateMaturityYears()`: This internal function calculates the number of years remaining until the bond's maturity date. It ensures that the maturity date is in the future and then calculates the number of years based on the difference between the maturity date and the current block's timestamp.

Overall, this abstract contract provides a foundation for representing and calculating the market value and market weight of corporate bonds. It also tracks key information about the bond issuer, coupon rate, maturity date, and bond rating. This contract can be extended by other contracts that implement specific functionality for debt tokens, such as trading, transfers, and other financial operations.

## AEquityToken

The provided Solidity abstract contract, `AEquityToken`, represents an equity token and appears to define a set of functions and state variables related to equity tokens. It inherits from the `IAccessControl` and `IEquityToken` interfaces, which may specify certain access control and equity-related functionality. Here's an analysis of the key components and functions in this contract:

**State Variables**:

1. `uint256 constant public SIXMONTHS`: This is a public constant variable set to 180 days, representing six months.
2. `uint256 constant public YEAR`: This is a public constant variable set to 365 days, representing one year.
3. `bool public TRADING_ACTIVE`: A public boolean variable that indicates whether trading of the equity token is currently active. It's initially set to `false`.
4. `bool public TRANSFERS_ACTIVE`: A public boolean variable that indicates whether transfers of the equity token are currently active. It's also initially set to `false`.
5. `uint256 public OUTSTANDING_SHARES`: This variable represents the number of outstanding shares of the equity token.
6. `uint256 public MAX_OFFERING_SHARES`: This variable specifies the maximum offering shares. It's initially set to `0`, indicating no maximum imposed.
7. `string public name`: This variable stores the name of the equity token.
8. `string public symbol`: This variable stores the symbol of the equity token.
9. `uint256 public totalSupply`: This variable represents the total supply of the equity token.
10. `uint256 public price`: This variable represents the price of the equity token.
11. `string public offeringType`: This variable is set to "EQUITY" and represents the type of the offering.

**Functions**:

1. `getName()`: This function allows external callers to retrieve the name of the equity token.
2. `getSymbol()`: This function allows external callers to retrieve the symbol of the equity token.
3. `getTotalSupply()`: This function allows external callers to retrieve the total supply of the equity token.
4. `getOfferingType()`: This function allows external callers to retrieve the offering type of the equity token.
5. `getTradingStatus()`: This function allows external callers to check the trading status of the equity token. It returns a boolean value.
6. `changeTradingStatus(bool status)`: This function allows changing the trading status of the equity token. It takes a boolean value as an argument to set the new status.
7. `getOutstandingShares()`: This function allows external callers to retrieve the number of outstanding shares of the equity token.
8. `getMarketValue()`: This function calculates and returns the market value of the equity token by multiplying its price by the number of outstanding shares.
9. `getMarketWeight(uint256 totalExchangeMarketValue)`: This function calculates and returns the market weight of the equity token relative to the total exchange market value. It normalizes the result to account for decimals and returns a percentage value.

Overall, this abstract contract provides a foundation for representing and managing equity tokens. It includes functions to access information about the token, manage trading status, and calculate market values and weights relative to an exchange. Additional functionality related to equity tokens can be implemented in contracts that inherit from this abstract contract.

## AExchangeFee

The provided Solidity abstract contract, `AExchangeFee`, appears to define a fee mechanism for an exchange. It implements the `IExchangeFee` interface and provides functions to set and manage the fee recipient and fee percentage. Here's an analysis of the key components and functions in this contract:

**State Variables**:

1. `address public feeRecipient`: This variable represents the address of the fee recipient, the party who receives the fees collected.
2. `uint256 public FeePercentage`: This variable represents the fee percentage charged for exchange transactions. It is initially set to 1%.

**Functions**:

1. `setFeeRecipient(address wallet) external`: This external function allows changing the fee recipient's address. It performs the following steps:

   - It stores the current `feeRecipient` in a variable `formerRecipient`.
   - It checks that the provided wallet address is not the null address (address(0x0)).
   - It sets the `feeRecipient` to the new wallet address.
   - It emits the `FeeRecipientChanged` event to log the change, providing the former and new recipients' addresses.
2. `setFeePercentage(uint256 amount) external`: This external function allows changing the fee percentage for exchange transactions. It performs the following steps:

   - It stores the current `FeePercentage` in a variable `formerAmount`.
   - It checks that the provided `amount` is greater than 0 and less than or equal to 100 (in the valid range of 0-100%).
   - It sets the `FeePercentage` to the new `amount`.
   - It emits the `FeePercentChanged` event to log the change, providing the former and new fee percentages.

**Events**:

1. `event FeeRecipientChanged(address formerRecipient, address newRecipient)`: This event is emitted when the fee recipient is changed. It logs the former recipient's address and the new recipient's address.
2. `event FeePercentChanged(uint256 formerAmount, uint256 newAmount)`: This event is emitted when the fee percentage is changed. It logs the former fee percentage and the new fee percentage.

This abstract contract provides a basic fee management system for an exchange, allowing for the dynamic setting of the fee recipient's address and the fee percentage. The use of this contract allows for flexibility in customizing the fee structure of the exchange, making it possible to adjust fees and designate where they are collected. However, the specific implementation details of how fees are collected and utilized in the exchange may be found in contracts that inherit from this abstract contract.

## ERC721

The provided Solidity abstract contract, `ERC721`, appears to represent a basic implementation of the ERC-721 standard for non-fungible tokens (NFTs). However, it's incomplete and lacks certain crucial functionalities, which are essential for a fully compliant and functional ERC-721 token. Here's an analysis of the contract's components and functions:

**State Variables**:

1. `_name` and `_symbol`: These variables store the name and symbol of the ERC-721 token.
2. `_owner`: This variable appears to be intended to store the address of the owner of the contract.
3. `_balance`: This variable is intended to store the balance of tokens of the contract's owner.
4. `mapping (address => uint256) private token_balances`: This mapping is supposed to store the token balances for each address.
5. `mapping (uint256 => address) private tokens`: This mapping is intended to store the owner of each token, indexed by the token ID.

**Constructor**:

- The constructor initializes the `_name` and `_symbol` variables with the provided name and symbol when the contract is deployed. However, it doesn't set the `_owner` or set any initial token balances.

**Functions**:

1. `balanceOf(address owner)`: This function allows querying the balance of tokens owned by a specific address. It returns the balance from the `token_balances` mapping.
2. `ownerOf(uint256 tokenId)`: This function allows querying the owner of a specific token ID. It returns the owner address from the `tokens` mapping.
3. `safeTransferFrom(address from, address to, uint256 tokenId)`: This function is intended to transfer a token from one address (`from`) to another address (`to`). It includes a basic check to ensure that the sender is the current owner of the token, but it doesn't implement the full ERC-721 standard, such as event emissions or transfer approval checks.
4. `transferFrom(address from, address to, uint256 tokenId)`: This function appears to perform a similar function as `safeTransferFrom`, transferring a token from one address to another. However, it lacks proper ERC-721 functionality and checks.
5. `approve(address to, uint256 tokenId)`, `getApproved(uint256 tokenId)`, `setApprovalForAll(address operator, bool _approved)`, and `isApprovedForAll(address owner, address operator)`: These functions are placeholders for the approval and operator management functions defined by the ERC-721 standard. They don't contain any actual logic and need to be properly implemented for full ERC-721 compliance.
6. `safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data)`: This function is a placeholder and doesn't contain any logic.

This contract is a very basic and incomplete implementation of the ERC-721 standard. To make it fully compliant and functional, you need to implement the missing features, including the ability to mint, transfer, approve, and manage NFTs as defined in the ERC-721 standard. Additionally, the contract lacks event emissions, which are crucial for tracking token transfers and approvals.
