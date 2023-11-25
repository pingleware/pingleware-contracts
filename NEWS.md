# Framework News

| Date       | Event                                                                                                                                                                                                               |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2023-11-25 | included assets/abi/** and build/contracts/** with a Node index.js to read ABI JSON and bytecode files using node require.                                                                                          |
| 2023-11-10 | moved Redeecash Exchange specific code to [https://github.com/redeecash](https://github.com/redeecash).                                                                                                               |
| 2023-11-02 | a standalone wallet generation application without connecting to a blockchain is available under[apps/wallet-creator](apps/wallet-creator)                                                                             |
| 2023-10-25 | test code implementation has starrted, with initial concentration on completing /finance/elmx and /finance/redeecash testing first                                                                                  |
| 2023-10-24 | truffle migrations completion with test stub code implemented. when contract changes, a new migration for that contract is started<br />using truffle migrate --from `<migration number> --to <migration number>` |
