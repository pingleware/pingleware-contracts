"use strict"

const fs = require('fs');
const path = require('path');
const os = require('os');

const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers')

var argv = yargs(hideBin(process.argv))
.option('iin', {
    type: 'string',
    description: 'Issuer Identification Number assigned by ansi.org',
    default: '60000',
    required: false
})
.option('panprefix', {
    type: 'string',
    description: 'The PAN prefix',
    default: '9840',
    required: false
})
.option('svc', {
    type: 'string',
    description: 'The Service Code',
    default: '999',
    required: false
})
.option('name', {
    type: 'string',
    description: 'The Member Name',
    default: 'John Doe',
    required: false
})
.option('mailing', {
    type: 'string',
    description: 'First line of the mailing address for the above NAME',
    default: '123 Maple Street',
    required: false
})
.option('csz', {
    type: 'string',
    description: 'City, State and Zip Code of the mailing address for the above NAME',
    default: 'Anytown, PA 17101',
    required: false
})
.option('date', {
    type: 'string',
    description: 'Welcome letter date',
    default: 'January 1, 2024',
    required: false
})
.option('out', {
    type: 'string',
    description: 'The output path to save the generated files',
    default: os.homedir(),
    required: false
})
.option('electron', {
    type: 'boolean',
    description: 'Start Electron User Interface',
    default: true,
    required: false
})
.parse()

const crypto = require('crypto');
const ethUtil = require('ethereumjs-util');
const CryptoJS = require('crypto-js');
const bip39 = require('bip39');
const QRCode = require('qrcode');
const generate = require('./letter');

const output_dir = argv['out'];

let mainWindow = null;

if (argv['electron'] == true) {
    const {app, BrowserWindow} = require('electron')

    // Keep a global reference of the window object, if you don't, the window will
    // be closed automatically when the JavaScript object is garbage collected.

    function createWindow () {
    // Create the browser window.
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 750,
        resizable: true,
        icon: path.join(__dirname,'image/logo.png'),
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: true,
            enableRemoteModule: false,
            preload: path.join(__dirname, 'preload.js')
        }
    })

    // and load the index.html of the app.
    mainWindow.loadFile(`views/index.html`)

    // Wait for the window to finish loading
    mainWindow.webContents.on('did-finish-load', () => {
        // Send the value 10 to the renderer process
    });
    // Open the DevTools.
    // mainWindow.webContents.openDevTools()
    mainWindow.once('ready-to-show', () => {
        //autoUpdater.checkForUpdatesAndNotify();
    });

    // Emitted when the window is closed.
    mainWindow.on('closed', function () {
        // Dereference the window object, usually you would store windows
        // in an array if your app supports multi windows, this is the time
        // when you should delete the corresponding element.
        mainWindow = null
    })
    }

    // This method will be called when Electron has finished
    // initialization and is ready to create browser windows.
    // Some APIs can only be used after this event occurs.
    app.on('ready', createWindow)

    // Quit when all windows are closed.
    app.on('window-all-closed', function () {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== 'darwin') app.quit()
    })

    app.on('activate', function () {
        // On macOS it's common to re-create a window in the app when the
        // dock icon is clicked and there are no other windows open.
        if (mainWindow === null) createWindow()
    })    
}

function DESEncryption(data, key) {
    const encryptedData = CryptoJS.DES.encrypt(data, key);
    return encryptedData;
}
function DESDecryption(data, key) {
    const decryptedData = CryptoJS.DES.decrypt(data, key);
    return decryptedData;
}
function calculateCVV(pan, expirationDate, serviceCode, key) {
    // Validate input lengths
    if (pan.length !== 16 && pan.length !== 19) {
        throw new Error('Invalid PAN length');
    }
    if (expirationDate.length !== 4) {
        throw new Error('Invalid expiration date length');
    }
    if (serviceCode.length !== 3) {
        throw new Error('Invalid service code length');
    }
    if (key.length !== 32) {
        throw new Error('Invalid key length');
    }

    // Step 5: Concatenate PAN, Expiry date, Service Code
    const concatenatedData = pan + expirationDate + serviceCode;

    // Step 6: Fill with zeroes to the right until you have 32 characters (assuming input is hex)
    const data = concatenatedData.padEnd(32, '0');

    // Step 7: Encrypt (DES) the first half of the data with the first half of the key
    const firstHalfData = data.substr(0, 16);
    const firstHalfKey = key.substr(0, 16);
    const encryptedFirstHalf = DESEncryption(firstHalfData, firstHalfKey).toString();

    // Step 8: XOR the result with the second half of Data
    const secondHalfData = data.substr(16, 16);
    const xoredData = xor(firstHalfData, secondHalfData);

    // Step 9: Encrypt (DES) the result with the first half of the Key
    const encryptedResult = DESEncryption(xoredData, firstHalfKey).toString();

    // Step 10: Decrypt the result with the second half of the key (reverse DES)
    const secondHalfKey = key.substr(16, 16);
    const decryptedResult = DESDecryption(encryptedResult, secondHalfKey).toString();

    // Step 11: Encrypt the result with the first half of the key (DES again)
    const finalEncryptedResult = DESEncryption(decryptedResult, firstHalfKey).toString();

    // Step 12: Get only the digits(numbers) from the result; First 3 are the CVV
    const cvv = findFirstThreeNumbers(finalEncryptedResult);

    return cvv;
}
function findFirstThreeNumbers(inputString) {
    const regex = /[0-9]/g; // Match one or more numeric digits
    const matches = inputString.match(regex);

    if (matches && matches.length >= 3) {
        // Return the first three numeric values as an array
        return matches.slice(0, 3).join('').replace(/,/g, '');
    } else {
        // Handle the case where there are fewer than three numeric values
        return '';
    }
}

// XOR function
function xor(a, b) {
    if (a.length !== b.length) {
        throw new Error('Input strings must have the same length for XOR operation.');
    }

    let result = '';
    for (let i = 0; i < a.length; i++) {
        // Convert characters to their ASCII codes and perform XOR operation
        const charCode1 = a.charCodeAt(i);
        const charCode2 = b.charCodeAt(i);
        const xorResult = charCode1 ^ charCode2;

        // Convert the XOR result back to a character
        result += String.fromCharCode(xorResult);
    }
    return result;
}

function generateExpirationDate(years=5) {
    const today = new Date();
    const year = (today.getFullYear() + years).toString().substring(2); // Get the last two digits of the year
    const month = (today.getMonth() + 1).toString().padStart(2, '0'); // Add 1 to get the current month (0-based index)
    return month + year;    
}
// Function to calculate the Luhn check digit
function calculateLuhnCheckDigit(input) {
    const digits = input.split('').map(Number);
    let sum = 0;
    let alternate = false;

    for (let i = digits.length - 1; i >= 0; i--) {
        let digit = digits[i];

        if (alternate) {
            digit *= 2;
            if (digit > 9) {
                digit -= 9;
            }
        }

        sum += digit;
        alternate = !alternate;
    }

    const checksum = (10 - (sum % 10)) % 10;
    return String(checksum);
}

// Function to generate a 32-bit hash
function generate32BitHash(pan) {
    const privateKey = crypto
    .createHmac('sha256', pan)
    .update(pan)
    .digest('hex');    
    //const privateKey = crypto.randomBytes(128).toString('hex');
    return '0x' + privateKey.substring(0,64);
}

if (argv['electron'] == false) {
    // Generate mnemonic
    const mnemonic = bip39.generateMnemonic()

    // Generate a random 32-byte private key. 
    // A PAN associated with a wallet private key is INSECURE because the PAN is psuedo-public used on eccomerce websites,
    // while the mnemonic is PRIVATE, never to be shared or disclosed.
    const privateKey = crypto.createHmac('sha256',mnemonic).digest(); //randomBytes(32);


    // Derive the corresponding public key
    const publicKey = ethUtil.privateToPublic(privateKey);

    // Derive the Ethereum address from the public key
    const address = ethUtil.pubToAddress(publicKey).toString('hex');

    /**
     * To be issued an Issuer Identification Number (IIN) from ANSI.ORG, you should have a state retail installment license or sales finance company license
     * 
     * Retail Installment License in Florida at https://flofr.gov/sitePages/RetailInstallmentSales.htm 
     * Sales Finance Company in Florida at https://flofr.gov/sitePages/SalesFinanceCompany.htm 
     *
     * then get an Issuer Identification Number from https://www.ansi.org/about/roles/registration-program/iin 
     * 
     */
    // The PAN is based on the Wallet address which does not change. If a new IIN is obtained, the PAN can be recreated from an existing
    // wallet address with a nw CVC, CVK and expiry date.
    //
    const iin = argv['iin'];
    const panPrefix = argv['panprefix'];
    // Generate a 9-digit unique wallet ID based on a timestamp and a random number
    // deepcode ignore GlobalReplacementRegex: the existing implementation is already working
    const walletId = parseInt(address,16).toString().replace('.','');
    // Concatenate the PAN components: Prefix (9840) + IIN (5 digits) + Wallet ID (9 digits), the 9840 prefix indicates private network
    const panBase = panPrefix + iin + walletId.toString().substring(0,6);
    // Calculate the Luhn check digit and append it to the PAN
    const luhnCheckDigit = calculateLuhnCheckDigit(panBase);
    const pan = panBase + luhnCheckDigit;

    const cvk = generate32BitHash(pan);

    // Generate a 3-digit service code (e.g., '123')
    const serviceCode = argv['svc'];
    const svcCode = (serviceCode + "000").substring(0, 3);

    const message = `Account Number: ${pan} for Wallet ${address}`;

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


    // Assign expiration date
    const expiry = generateExpirationDate(); // option years parameter for future expiration date
    const cvv = calculateCVV(pan,expiry,svcCode,signatureHex.substring(0,32));


    console.log('Private Key (hex):', privateKey.toString('hex'));
    console.log('Public Key (hex):', publicKey.toString('hex'));
    console.log('Ethereum Address:', `0x${address}`);
    console.log('Primary Account Number:', pan);
    console.log('Expiration Date:', expiry);
    console.log('CVV:', cvv);
    console.log('CVK:', cvk);
    console.log('Service Code:', svcCode);
    console.log('Password:', signatureHex); // this password is saved to the off-chain database associated with the ethereum address
    console.log('Mnemonic:',mnemonic);

    const walletInfo = {
        OWNER: argv['name'],
        PAN: pan,
        EXP: expiry,
        CVV: cvv,
        CVK: cvk,
        SVC: svcCode,
        ADDRESS: `0x${address}`,
        PUBLICKEY: publicKey.toString('hex'),
        PRIVATEKEY: privateKey.toString('hex'),
        PASSWORD: signatureHex,
        MNEMONIC: mnemonic
    };

    fs.writeFileSync(path.join(output_dir,`${pan}.json`),JSON.stringify(walletInfo));

    const hwCrypto = {
        owner: argv['name'],
        wallet_name: "redeecash",
        mnemonic_phrase: mnemonic,
        bip32_path: "m/44'/60'/0'/0",
        accounts: [
            {
                account_name: `0x${address}`,
                extended_public_key: publicKey.toString('hex'),
                balance: "",
                transactions: []    
            }
        ]
    }

    fs.writeFileSync(path.join(output_dir,`${pan}.wallet.json`),JSON.stringify(hwCrypto));

    // Create an Ethereum URI to import the wallet into MetaMask
    const ethereumUri = `ethereum:0x${address}?private_key=${privateKey.toString('hex')}`;

    // Generate a QR code for the Ethereum URI
    QRCode.toFile(path.join(output_dir,`${pan}.png`), ethereumUri, function (err) {
        if (err) {
        console.error(err);
        } else {
        console.log(`QR code saved as ${pan}.png`);
        const qrcode_file = fs.readFileSync(path.join(output_dir,`${pan}.png`)).toString('base64');
        const contents = generate(argv['name'],`0x${address}`,publicKey.toString('hex'),privateKey.toString('hex'),qrcode_file,mnemonic,argv['mailing'],argv['csz'],argv['date'],pan);
        fs.writeFileSync(path.join(output_dir,`${pan}.html`),contents);
        console.log(`Welcome letter saved as ${pan}.html`);
        const base64 = btoa(JSON.stringify(contents));
        fs.writeFileSync(path.join(output_dir,`${pan}.base64`),base64)
        console.log(`Welcome letter as base64: ${pan}.base64`);
        }
    });
} else {
    const { ipcMain } = require('electron');

    ipcMain.on("create", function(evt, params){
        console.log(params);

        const name = params.name;
        const mailing = params.mailing;
        const csz = params.csz;
        const date = params.date;
        const iin = params.iin;
        const panPrefix = params.panPrefix;
        const serviceCode = params.serviceCode;
        const out = params.out;

        const mnemonic = bip39.generateMnemonic()
        const privateKey = crypto.createHmac('sha256',mnemonic).digest();
        const publicKey = ethUtil.privateToPublic(privateKey);
        const address = ethUtil.pubToAddress(publicKey).toString('hex');

        const walletId = parseInt(address,16).toString().replace('.','');

        const panBase = panPrefix + iin + walletId.toString().substring(0,6);
        const luhnCheckDigit = calculateLuhnCheckDigit(panBase);

        const pan = panBase + luhnCheckDigit;

        const cvk = generate32BitHash(pan);

        const svcCode = (serviceCode + "000").substring(0, 3);

        const message = `Account Number: ${pan} for Wallet ${address}`;
    
        const privateKeyBuffer = Buffer.from(privateKey.toString('hex'), 'hex');
        const prefixedMessage = ethUtil.hashPersonalMessage(Buffer.from(message));

        const signature = ethUtil.ecsign(
            prefixedMessage,
            privateKeyBuffer
        );
    
        const concatenatedSignature = signature.r.toString('hex') + signature.s.toString('hex') + signature.v;
        const signatureBuffer = Buffer.from(concatenatedSignature, 'hex');
        const signatureHex = signatureBuffer.toString('hex');

        const expiry = generateExpirationDate(); // option years parameter for future expiration date
        const cvv = calculateCVV(pan,expiry,svcCode,signatureHex.substring(0,32));
            

        const ethereumUri = `ethereum:0x${address}?private_key=${privateKey.toString('hex')}`;

        // Generate a QR code for the Ethereum URI
        QRCode.toFile(path.join(output_dir,`${pan}.png`), ethereumUri, function (err) {
            if (err) {
                console.error(err);
            } else {
                console.log(`QR code saved as ${pan}.png`);
                const qrcode_file = fs.readFileSync(path.join(output_dir,`${pan}.png`)).toString('base64');
                const contents = generate(name,`0x${address}`,publicKey.toString('hex'),privateKey.toString('hex'),qrcode_file,mnemonic,mailing,csz,date,pan);
                const base64 = btoa(JSON.stringify(contents));

                const result = {
                    OWNER: params.name,
                    PAN: pan,
                    EXP: expiry,
                    CVV: cvv,
                    CVK: cvk,
                    SVC: svcCode,
                    ADDRESS: `0x${address}`,
                    PUBLICKEY: publicKey.toString('hex'),
                    PRIVATEKEY: privateKey.toString('hex'),
                    PASSWORD: signatureHex,
                    MNEMONIC: mnemonic,
                    HTML: base64  
                }        
    
                mainWindow.webContents.send("create", result);
            }
        });
    })
}
