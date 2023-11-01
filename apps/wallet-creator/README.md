# Wallet Creator

A standalone application that will create an ethereum wallet address with public and private keys and create a sign hash from a string message that can be used as a password when authenticating. The password should be stored in an off chain database with reference to the wallet address. DO NOT STORE THE PRIVATE KEYS IN THE OFF CHAIN DATABASE.

The public and private keys along with the wallet are sent to the user via a secured method. The user will import their new wallet into metamask using the private key.

## TODO

Store the keys on a hardware USB wallet that can interact with metamask.
