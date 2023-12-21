const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
// using WebEncrypt to encrypt the jsonString using the privateKey
const {webdevencrypt} = require('@presspage/common-js');
// compress encrypted data
const zlib = require('zlib');

function generateRandomNumber(min, max) {
    // Returns a random integer between min (inclusive) and max (inclusive)
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
  
function generateRandomNumbersFix(min,max,count) {
    if (count > max - min + 1) {
        console.error('Cannot generate more unique numbers than the range allows.');
        return [];
      }
    
      const uniqueNumbers = new Set();
    
      while (uniqueNumbers.size < count) {
        const randomNumber = generateRandomNumber(min, max);
        uniqueNumbers.add(randomNumber);
      }
    
    return Array.from(uniqueNumbers).sort((a, b) => a - b);
  }
  
  function generateRandomNumbersForCorners() {
    const randomNumbers = [];
    const group1 = generateRandomNumbersFix(1,15,2);
    const group2 = generateRandomNumbersFix(61,75,2);
    randomNumbers.push(group1[0],group1[1],group2[0],group2[1]);
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
  
  let ticketCount = 1;
  const ticketPrice = 1; // as per FS 849.0931 13(a)
  const payout = Number((ticketCount * ticketPrice) * 0.65).toFixed(2);
  const earnings = (Number(ticketCount * ticketPrice) - Number(payout)).toFixed(2);
  
  let numbers = [];
  let flares = [];
  
  const serialNo = generateUniqueSerialNumber(); // per FS 849.0931 13(d)
  
  let bingo = {}, metadata;
  
  let publicKey, privateKey;
  
// before each
async function initialize(game,_ticketCount) {
    ticketCount = _ticketCount;

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
                    if (i==2) {
                        N.push(0);  // push a FREE space
                    } else {
                        N.push(bingoGrid[letter][i])
                    }
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
            name: `GAME ${game}`,
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
    let third = (Number(payout) / 3).toFixed(0);
    let half = (Number(payout) / 2).toFixed(0);
    bingo = {
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
          instructions: `You have four chances to win on a single ticket. Look for matches for each rack set (single line, four corners, and two lines). Mark only the squares with a match. If you get two of four corners, you win half ($${half}) of the jackpot, if no other winners. If you get three of four corners, you win a third ($${third}) of the jackpot, if no other winners.`,
          rules: `If won, you must wait for all ${ticketCount} tickets to be sold before you can complete the redemptiom to claim your prize. If you are the only winner, then you will the jackpot of $${payout}. If there are multiple winners, the jackpot of $${payout} is divided equally among the winners. If there no winners after all ${ticketCount} tickets sold, then jackpot of $${payout} will be divided equally among the players of this game. If you played another game, but not this game, you will not be included in the disbutsement. If there are ONLY two winners with two corners and no other winners, the half ($${half}) of the jackpot is split between each winner, the remaining half will be pool for a future game. If there are only three corner winners, the third of the jackpot is shared among the winners while the remaining will be added to pool. There greater the winning combination over four corners take precendence, if there are no row or four corners. Multiple winners, the jackpot will be split equally.`,
          law: "This Instant Bingo is govern under Florida Statute 849.0931 and purchase of a bingo ticket does not constitute a tax deductible donation.",
          blockchain: "Blockchain Instant Bingo maintains an immutable collection of each game tickets in an encrypted form so any winners are not disclosed early and tickets cannot be altered."  
      },
    }  
    //console.log(bingo);
    // create or load key pairs
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
}

// create new game
async function createNewGame(InstantBingo) {
    const now = new Date();
    const start_time = now.getTime();
    const end_time = new Date(now.getTime() + 60 * 60 * 1000).getTime();
    const tx = await InstantBingo.newGame(start_time,end_time,bingo.session.deal.serialNo,bingo.session.deal.ticketCount);
    //console.log(tx.logs[0]);    
    return tx.logs[0];
}

// add game card
async function addGameCard(game,InstantBingo) {
    let tx = null;
    let oneCorner = 0;
    let twoCorner = 0;

    bingo.session.flare.forEach(async function(flare) {
        //console.log([flare.rack.fourCorners,flare.grid]);
        
        let originalArray = [
                                flare.grid.B[0],flare.grid.I[0],flare.grid.N[0],flare.grid.G[0],flare.grid.O[0],
                                flare.grid.B[4],flare.grid.I[4],flare.grid.N[4],flare.grid.G[4],flare.grid.O[4]
                            ];

        let originalRowArray = [
            flare.grid.B[0],flare.grid.B[1],flare.grid.B[2],flare.grid.B[3],flare.grid.B[4],
            flare.grid.I[0],flare.grid.I[1],flare.grid.I[2],flare.grid.I[3],flare.grid.I[4],
            flare.grid.N[0],flare.grid.N[1],flare.grid.N[3],flare.grid.N[4],
            flare.grid.G[0],flare.grid.G[1],flare.grid.G[2],flare.grid.G[3],flare.grid.G[4],
            flare.grid.O[0],flare.grid.O[1],flare.grid.O[2],flare.grid.O[3],flare.grid.O[4],
            flare.grid.B[0],flare.grid.I[0],flare.grid.N[0],flare.grid.G[0],flare.grid.O[0],
            flare.grid.B[1],flare.grid.I[1],flare.grid.N[1],flare.grid.G[1],flare.grid.O[1],
            flare.grid.B[2],flare.grid.I[2],flare.grid.G[2],flare.grid.O[2],
            flare.grid.B[3],flare.grid.I[3],flare.grid.N[3],flare.grid.G[3],flare.grid.O[3],
            flare.grid.B[4],flare.grid.I[4],flare.grid.N[4],flare.grid.G[4],flare.grid.O[4],
            flare.grid.B[0],flare.grid.I[1],flare.grid.G[3],flare.grid.O[4],
            flare.grid.B[4],flare.grid.I[3],flare.grid.G[1],flare.grid.O[0],
        ];

        //let winner = [false,false,false];
        let winner = matchCornerNumbers(originalArray,flare.rack.fourCorners);
        if (winner) {
            console.log(`four corner winner found!`);
        }

        flare.rack.fourCorners.forEach(function(corner) {
            if (flare.grid.B[0] == corner || flare.grid.B[4] == corner || flare.grid.O[0] == corner || flare.grid.O[4] == corner) {
                oneCorner++;
            }
        })
        if ((flare.grid.B[0] == flare.rack.fourCorners[0] || flare.grid.B[4] == flare.rack.fourCorners[1]) && 
            (flare.grid.O[0] == flare.rack.fourCorners[2] || flare.grid.O[4] == flare.rack.fourCorners[3])) {
            console.log([flare.grid.B,flare.grid.O,flare.rack.fourCorners]);
            twoCorner++;
        }

        
        try {
            const jsonString = JSON.stringify(flare);
            const encryptedData = webdevencrypt.setEncrypt(jsonString,privateKey)
            //console.log(btoa(encryptedData).length);
        
            // Step 1: Compress the Data
            const compressedData = zlib.gzipSync(encryptedData);
        
            // Sign the encrypted string with the private key
            const sign = crypto.createSign('SHA256');
            sign.update(compressedData);
            const signature = sign.sign(privateKey, 'base64');
        
            metadata = {
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
        
            //console.log(metadata);
        
            tx = await InstantBingo.addGameCard(game,metadata.formNumber,metadata.ticket,metadata.signature);    
        } catch(error) {
            console.error(error);
        }
      });    
      console.log(`Cards with at least one corner match: ${oneCorner}`);
      console.log(`Cards with at least two corner match: ${twoCorner}`);
      return tx;
}

/**
 * // Example usage
 * const originalArray = [1, 2, 3, 4, 5, 6, 7, 8, 9];
 * const cornerNumbersToMatch = [1, 9, 9, 1]; // Replace with the actual corner numbers you want to check
 * 
 * const isMatch = matchCornerNumbers(originalArray, cornerNumbersToMatch);
 * 
 * if (isMatch) {
 *   console.log('The array matches the specified corner numbers.');
 * } else {
 *   console.log('The array does not match the specified corner numbers.');
 * }
 * 
 * @param {*} array 
 * @param {*} cornerNumbers 
 * @returns 
 */
function matchCornerNumbers(array, cornerNumbers) {
    // Check if the array has at least four elements
    if (array.length < 4) {
      console.error('Array must have at least four elements.');
      return false;
    }
  
    // Extract the corner numbers from the array
    const extractedCornerNumbers = [
      array[0],                   // Top-left corner
      array[array.length - 1],    // Top-right corner
      array[array.length - 1],    // Bottom-right corner
      array[0]                    // Bottom-left corner
    ];
  
    // Compare the extracted corner numbers with the provided cornerNumbers array
    for (let i = 0; i < 4; i++) {
      if (extractedCornerNumbers[i] !== cornerNumbers[i]) {
        return false; // Mismatch found
      }
    }
  
    return true; // All corner numbers match
  }

/**
 * // Example usage
 * const originalArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
 * const rowNumbersToMatch = [1, 2, 3, 4, 5]; // Replace with the actual row numbers you want to check
 * 
 * const isMatch = matchRow(originalArray, rowNumbersToMatch);
 * 
 * if (isMatch) {
 *   console.log('The row of numbers matches the specified row numbers.');
 * } else {
 *   console.log('The row of numbers does not match the specified row numbers.');
 * }
 * 
 * @param {*} array 
 * @param {*} rowNumbers 
 * @returns 
 */
function matchRow(array, rowNumbers) {
    // Check if the array has at least five elements
    if (array.length < 5) {
      console.error('Array must have at least five elements.');
      return false;
    }
  
    // Extract the row of numbers from the array
    const extractedRow = array.slice(0, 5);
  
    // Compare the extracted row with the provided rowNumbers array
    for (let i = 0; i < 5; i++) {
      if (extractedRow[i] !== rowNumbers[i]) {
        return false; // Mismatch found
      }
    }
  
    return true; // All numbers in the row match
  }

/**
 * // Example usage
 * const originalArray = [
 *   1, 2, 3, 4, 5,
 *   6, 7, 8, 9, 10,
 *   11, 12, 13, 14, 15,
 *   16, 17, 18, 19, 20,
 *   21, 22, 23, 24, 25
 * ];
 * 
 * const diagonalNumbersToMatch = [1, 7, 13, 19, 25]; // Replace with the actual diagonal numbers you want to check
 * const startRow = 0; // Replace with the starting row index of the diagonal
 * const startCol = 0; // Replace with the starting column index of the diagonal
 * const direction = 'down'; // Specify 'up' or 'down' for the direction of the diagonal
 * 
 * const isMatch = matchDiagonal(originalArray, diagonalNumbersToMatch, startRow, startCol, direction);
 * 
 * if (isMatch) {
 *   console.log('The diagonal line of numbers matches the specified diagonal numbers.');
 * } else {
 *   console.log('The diagonal line of numbers does not match the specified diagonal numbers.');
 * }
 * 
 * @param {*} array 
 * @param {*} diagonalNumbers 
 * @param {*} startRow 
 * @param {*} startCol 
 * @param {*} direction 
 * @returns 
 */
function matchDiagonal(array, diagonalNumbers, startRow, startCol, direction) {
    // Check if the array has enough elements for a diagonal line
    if (array.length < 5 * 5) {
      console.error('Array must have at least 5x5 elements for a diagonal line check.');
      return false;
    }
  
    const extractedDiagonal = [];
  
    // Extract the diagonal numbers based on the starting position and direction
    for (let i = 0; i < 5; i++) {
      const rowIndex = startRow + (direction === 'up' ? -i : i);
      const colIndex = startCol + i;
      const index = rowIndex * 5 + colIndex;
  
      extractedDiagonal.push(array[index]);
    }
  
    // Compare the extracted diagonal with the provided diagonalNumbers array
    for (let i = 0; i < 5; i++) {
      if (extractedDiagonal[i] !== diagonalNumbers[i]) {
        return false; // Mismatch found
      }
    }
  
    return true; // All numbers in the diagonal match
  }
  

module.exports = {
    initialize,
    createNewGame,
    addGameCard,
    matchCornerNumbers,
    matchRow,
    matchDiagonal
}