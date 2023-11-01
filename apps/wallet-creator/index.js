"use strict"

const crypto = require('crypto');
const ethUtil = require('ethereumjs-util');

// Generate an Ethereum wallet

// Generate a random 32-byte private key
const privateKey = crypto.randomBytes(32);

// Derive the corresponding public key
const publicKey = ethUtil.privateToPublic(privateKey);

// Derive the Ethereum address from the public key
const address = ethUtil.pubToAddress(publicKey).toString('hex');

const message = 'A COMMON MESSAGE THAT ALL USERS SIGN ON A WEBSITE FOR AUTHENTICATING THE USE';

// Convert the private key from hex to a buffer
const privateKeyBuffer = Buffer.from(privateKey.toString('hex'), 'hex');

// Add the Ethereum message prefix to the message
const prefixedMessage = ethUtil.hashPersonalMessage(Buffer.from(message));


// Sign the message
const signature = ethUtil.ecsign(
    prefixedMessage,
    privateKeyBuffer
);

const concatenatedSignature = signature.r.toString('hex') + signature.s.toString('hex') + signature.v;

// Convert the concatenated signature to a buffer
const signatureBuffer = Buffer.from(concatenatedSignature, 'hex');

// Convert the buffer to a hexadecimal string
const signatureHex = signatureBuffer.toString('hex');

console.log('Private Key (hex):', privateKey.toString('hex'));
console.log('Public Key (hex):', publicKey.toString('hex'));
console.log('Ethereum Address:', `0x${address}`);
console.log('Password:', signatureHex); // this password is saved to the off-chain database associated with the ethereum address