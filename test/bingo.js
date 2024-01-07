/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("games/Bingo", function (/* accounts */) {
    
});

// Function to generate a random number within a specified range
function generateRandomNumber(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

function generateRandomNumbersFix(min,max,count) {
    const randomNumbers = [];
    for (let i = 0; i < count; i++) {
      const randomNumber = Math.floor(Math.random() * (max - min + 1)) + min;
      randomNumbers.push(randomNumber);
    }
    return randomNumbers.sort((a, b) => a - b);
}

function generateRandomNumbersForSingleLine() {
    let randomNumbers = [];
    let randomNumber = Math.floor(Math.random() * 15) + 1;
    randomNumbers.push(randomNumber);
    randomNumber = Math.floor(Math.random() * 15) + 16;
    randomNumbers.push(randomNumber);
    randomNumber = Math.floor(Math.random() * 15) + 31;
    randomNumbers.push(randomNumber);
    randomNumber = Math.floor(Math.random() * 15) + 46;
    randomNumbers.push(randomNumber);
    randomNumber = Math.floor(Math.random() * 15) + 61;
    randomNumbers.push(randomNumber);
    return randomNumbers.sort((a, b) => a - b);
}

function generateRandomNumbersForCorners() {
    const randomNumbers = [];
    for (let i = 0; i < 2; i++) {
      const randomNumber = Math.floor(Math.random() * 15) + 1;
      randomNumbers.push(randomNumber);
    }
    for (let i = 0; i < 2; i++) {
      const randomNumber = Math.floor(Math.random() * 15) + 61;
      randomNumbers.push(randomNumber);
    }
    return randomNumbers.sort((a, b) => a - b);
}
  
function generateUniqueSerialNumber() {
    const timestamp = new Date().getTime(); // Get the current timestamp
    const randomPart = Math.floor(Math.random() * 10000); // Generate a random number
  
    // Combine the timestamp and random part to create a unique serial number
    const serialNumber = `${timestamp}${randomPart}`;
  
    return serialNumber;
  }
    
  // Function to generate a Bingo grid
function generateBingoGrid() {
    const grid = {
      B: [],
      I: [],
      N: [],
      G: [],
      O: [],
    };
  
    // Generate numbers for each column
    for (let letter of Object.keys(grid)) {
      const min = (letter === 'B') ? 1 : (letter === 'I') ? 16 : (letter === 'N') ? 31 : (letter === 'G') ? 46 : 61;
      const max = min + 14; // Each column has 15 numbers
  
      for (let i = 0; i < 5; i++) {
        let randomNum;
        do {
          randomNum = generateRandomNumber(min, max);
        } while (grid[letter].includes(randomNum));
        grid[letter].push(randomNum);
      }
      grid[letter].sort((a, b) => a - b); // Sort the column in ascending order
    }
  
    return grid;
}


const ticketCount = 5;
const ticketPrice = 1; // as per FS 849.0931 13(a)
const payout = (Number(ticketCount * ticketPrice) * 0.65).toFixed(2);
const earnings = (Number(ticketCount * ticketPrice) - Number(payout)).toFixed(2);

let numbers = [];
let flares = [];

const serialNo = generateUniqueSerialNumber(); // per FS 849.0931 13(d)

for (let i=0; i < ticketCount; i++) {
    let formNo = Number(new Date().getTime()) + Number(Math.random() * 1000);
    formNo = Number(formNo).toFixed(0);

    numbers.push({
        formNo: formNo,
        serialNo: serialNo,
    })

     // Generate the Bingo grid
    const bingoGrid = generateBingoGrid();
    
    let B=[],I=[],N=[],G=[],O=[];
    for (let i = 0; i < 5; i++) {
        let row = '';
        for (let letter of ['B', 'I', 'N', 'G', 'O']) {
          row += ` ${bingoGrid[letter][i]}   `;
          switch(letter) {
            case 'B':
                B.push(bingoGrid[letter][i])
                break;
            case 'I':
                I.push(bingoGrid[letter][i])
                break;
            case 'N':
                N.push(bingoGrid[letter][i])
                break;
            case 'G':
                G.push(bingoGrid[letter][i])
                break;
            case 'O':
                O.push(bingoGrid[letter][i])
                break;
          }
        }
    }

    const grid = {
        B: B,
        I: I,
        N: N,
        G: G,
        O: O
    } 
    //console.log(grid);
    const rack = {
        singleLine: generateRandomNumbersFix(1,75,5),
        fourCorners: generateRandomNumbersForCorners(),
        twoLines: generateRandomNumbersFix(1,75,10),
    }

    // TODO: verification needed that no two flares are alike, no duplicate grids
    flares.push({
        name: "GAME ONE",
        manufacturer: "AMERIONE CORPORATION",
        formNumber: formNo,
        ticketCount: ticketCount,
        prizeStructure: "Community Jackpot",
        price: ticketPrice,
        serialNo: serialNo,
        rack: rack,
        grid: grid,  
        qrcode: "",  
    });
}
const bingo = {
    session: {
        payout: payout,
        earnings: earnings,        
        deal: {
            dateOfSale: new Date().toISOString(),
            numbers: numbers,
            ticketCount: ticketCount,
            manufacturer: "AMERIONE CORPORATION",
            price: ticketPrice,
            serialNo: serialNo,
        },
        flare: flares,
        instructions: "You have three chances to win on a single ticket. Look for matches for each rack set (single line, four corners, and two lines). Mark only the squares with a match.",
        rules: `If won, you must wait for all ${ticketCount} tickets to be sold before you can complete the redemptiom to claim your prize. If you are the only winner, then you will the jackpot of $${payout}. If there are multiple winners, the jackpot of $${payout} is divided equally among the winners. If there no winners after all ${ticketCount} tickets sold, then jackpot of $${payout} will be divided equally among the players of this game. If you played another game, but not this game, you will not be included in the disbutsement.`,
        law: "This Instant Bingo is govern under Florida Statute 849.0931 and purchase of a bingo ticket does not constitute a tax deductible donation.",
        blockchain: "Blockchain Instant Bingo maintains an immutable collection of each game tickets in an encrypted form so any winners are not disclosed early and tickets cannot be altered."  
    },
}
console.log(bingo);

// per FS 849.0931 13(f)(4)
// create a signed hash of JSON.stringify(bingo) using a public key, the private key on the secured website is used to decrypt the bingo ticket upon a purchase
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

let publicKey, privateKey;

if (!fs.existsSync(path.join(__dirname,'public.key'))) {
    // Generate key pair
    const { _publicKey, _privateKey } = crypto.generateKeyPairSync('rsa', {
        modulusLength: 2048, // You can adjust the key size
        publicKeyEncoding: {
            type: 'spki',
            format: 'pem',
        },
        privateKeyEncoding: {
            type: 'pkcs8',
            format: 'pem',
        },
    });
    publicKey = _publicKey;
    privateKey = _privateKey;

  
    fs.writeFileSync(path.join(__dirname,'public.key'),publicKey);
    fs.writeFileSync(path.join(__dirname,'private.key'),privateKey);
} else {
    publicKey = fs.readFileSync(path.join(__dirname,'public.key')).toString();
    privateKey = fs.readFileSync(path.join(__dirname,'private.key')).toString();
}

// Print the public and private keys
console.log('Public Key:\n', publicKey);
console.log('\nPrivate Key:\n', privateKey);


// using WebEncrypt to encrypt the jsonString using the privateKey
const {webdevencrypt} = require('@presspage/common-js');
// compress encrypted data
const zlib = require('zlib');

bingo.session.flare.forEach(function(flare) {
    const jsonString = JSON.stringify(flare);
    const encryptedData = webdevencrypt.setEncrypt(jsonString,privateKey)
    //console.log(btoa(encryptedData).length);

    // Step 1: Compress the Data
    const compressedData = zlib.gzipSync(encryptedData);

    // Sign the encrypted string with the private key
    const sign = crypto.createSign('SHA256');
    sign.update(compressedData);
    const signature = sign.sign(privateKey, 'base64');

    const metadata = {
        name: flare.name,
        manufacturer: flare.manufacturer,
        formNumber: flare.formNumber,
        ticketCount: flare.ticketCount,
        prizeStructure: flare.prizeStructure,
        price: flare.price,
        serialNo: flare.serialNo,
        ticket: compressedData.toString("base64"),
        signature: signature,
    }

    console.log(metadata);
})