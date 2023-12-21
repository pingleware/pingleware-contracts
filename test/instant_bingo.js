
const InstantBingo = artifacts.require("InstantBingo");

const {
  initialize,
  createNewGame,
  addGameCard,
  matchCornerNumbers,
  matchRow,
  matchDiagonal
} = require("./instant_bingo_lib");

let game = 0;

/*
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("InstantBingo", function (accounts) {
  before(async function(){
    const contractInstance = await InstantBingo.deployed();
    const games = await contractInstance.getGames();
    game = games.length;
    console.log(game);
  })
  it("should assert true", async function () {
    await InstantBingo.deployed();
    return assert.isTrue(true);
  });
  it(`intialize`,async function(){
    initialize(game,500);
  })
  it(`create a new game`, async function(){
    const contractInstance = await InstantBingo.deployed();
    const tx = await createNewGame(contractInstance);
    //console.log(tx);
    return assert.isTrue(true);
  })
  it(`get games`,async function(){
    const contractInstance = await InstantBingo.deployed();
    const games = await contractInstance.getGames();
    //console.log(games);
    return assert.isTrue(true);
  })
  it(`add #2 wallet as a player`,async function(){
    try {
      const contractInstance = await InstantBingo.deployed();
      const tx = await contractInstance.addPlayer(accounts[1]);
      //console.log(tx);  
    } catch(error) {
      //console.log(error.reason);
      return assert.isTrue(error.reason == "player is already added");
    }
    return assert.isTrue(true);
  })
  it(`get contract balance`,async function(){
    const contractInstance = await InstantBingo.deployed();
    const balance = await contractInstance.getContractBalance();
    //console.log(balance.toNumber());
    return assert.isTrue(true);
  })
  it(`add game cards for new game`,async function(){
    const contractInstance = await InstantBingo.deployed();
    const tx = await addGameCard(game,contractInstance);
    //console.log(tx);
    return assert.isTrue(true);
  })
  it(`get first card from the latest game`,async function(){
    try {
      const contractInstance = await InstantBingo.deployed();
      const card = await contractInstance.getGameCardNumbers(game-1,0);
      //console.log(card);  
    } catch(error) {
      //console.log(error)
    }
    return assert.isTrue(true);
  })
  it(`buy ticket from latest game`, async function(){
    const contractInstance = await InstantBingo.deployed();
    //console.log(game-1)
    const tx = await contractInstance.buyTicket(game-1,0,{from: accounts[1], value: (489411062379160)});
    //console.log(tx.logs[0].args);
    return assert.isTrue(true);
  })
  it(`get players cards`,async function(){
    const contractInstance = await InstantBingo.deployed();
    const cards = await contractInstance.getPlayerTickets({from: accounts[1]});
    //console.log(cards);
    return assert.isTrue(true);
  })
});
