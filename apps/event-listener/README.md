# Event Listener

The Event Listener will listen to the event notifications sent by the framework regardless on which blockchain the framework is deployed.

![1703331254117](image/README/1703331254117.png)

## Events

| Group          | Sub-Group | File                  | Event                       | Arguments                                                                                         |
| -------------- | --------- | --------------------- | --------------------------- | ------------------------------------------------------------------------------------------------- |
| agriculture    |           |                       |                             |                                                                                                   |
|                |           | AgriChain.sol         |                             |                                                                                                   |
|                |           |                       | ProductAdded                | uint prodId, string pname, string pstatus, string pcurLoc, bytes32 hash                           |
| aircraft       |           |                       |                             |                                                                                                   |
|                |           | AircraftOwnership.sol |                             |                                                                                                   |
|                |           |                       | Transfer                    | address sender, address receiver, uint amount                                                     |
| common         |           |                       |                             |                                                                                                   |
|                |           | Account.sol           |                             |                                                                                                   |
|                |           |                       | AccountBalanceTransfer      | address sender,address receiver,uint256 amount                                                    |
|                |           |                       | AccountTransfer             | address sender,address receiver,uint256 amount                                                    |
|                |           | Destructible.sol      |                             |                                                                                                   |
|                |           |                       | Destroyed                   | address sender, address recipient                                                                 |
|                |           |                       | Termination                 | address sender, string reason                                                                     |
|                |           | Frozen.sol            |                             |                                                                                                   |
|                |           |                       | Started                     | address sender, string reason                                                                     |
|                |           |                       | Stopped                     | address sender, string reason                                                                     |
|                |           | IdentityRegistry.sol  |                             |                                                                                                   |
|                |           |                       | IdentityAdded               | address indexed addressAdded, string identityHash, address indexed authorizedBy                   |
|                |           |                       | IdentityUpdated             | address indexed updatedAddress, string previousHash, string newHash, address indexed authorizedBy |
|                |           | Owned.sol             |                             |                                                                                                   |
|                |           |                       | FallbackEvent               | address sender, uint256 amount                                                                    |
|                |           |                       | ReceiveEvent                | address sender, uint256 amount                                                                    |
|                |           |                       | OwnershipTransferred        | address indexed previousOwner, address indexed newOwner                                           |
|                |           | Whitelistable.sol     |                             |                                                                                                   |
|                |           |                       | AddressAddedToWhitelist     | address indexed AuthorizedBy, address indexed AddressAdded                                        |
|                |           |                       | AddressRemovedFromWhitelist | address indexed AuthorizedBy, address indexed AddressRemoved                                      |
| education      |           |                       |                             |                                                                                                   |
| energy         |           |                       |                             |                                                                                                   |
| finance        |           |                       |                             |                                                                                                   |
|                | banking   |                       |                             |                                                                                                   |
|                | credit    |                       |                             |                                                                                                   |
|                | currency  |                       |                             |                                                                                                   |
|                | dao       |                       |                             |                                                                                                   |
|                | debt      |                       |                             |                                                                                                   |
|                | elmx      |                       |                             |                                                                                                   |
|                | equity    |                       |                             |                                                                                                   |
|                | rcex      |                       |                             |                                                                                                   |
|                | utility   |                       |                             |                                                                                                   |
| games          |           |                       |                             |                                                                                                   |
| government     |           |                       |                             |                                                                                                   |
|                | county    |                       |                             |                                                                                                   |
|                | federal   |                       |                             |                                                                                                   |
|                | municipal |                       |                             |                                                                                                   |
|                | state     |                       |                             |                                                                                                   |
| healthcare     |           |                       |                             |                                                                                                   |
|                | pharma    |                       |                             |                                                                                                   |
| hospitality    |           |                       |                             |                                                                                                   |
| insurance      |           |                       |                             |                                                                                                   |
| interfaces     |           |                       |                             |                                                                                                   |
| legal          |           |                       |                             |                                                                                                   |
| libs           |           |                       |                             |                                                                                                   |
| membership     |           |                       |                             |                                                                                                   |
| news           |           |                       |                             |                                                                                                   |
| nft            |           |                       |                             |                                                                                                   |
| non-profit     |           |                       |                             |                                                                                                   |
| realestate     |           |                       |                             |                                                                                                   |
| retail         |           |                       |                             |                                                                                                   |
| scm            |           |                       |                             |                                                                                                   |
| social         |           |                       |                             |                                                                                                   |
| technology     |           |                       |                             |                                                                                                   |
| transportation |           |                       |                             |                                                                                                   |
