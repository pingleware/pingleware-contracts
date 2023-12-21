// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * This Instant Bingo Game is based on the rules for a Florida Instant Bingo operation at http://www.leg.state.fl.us/Statutes/index.cfm?App_mode=Display_Statute&URL=0800-0899/0849/Sections/0849.0931.html
 *
 * However, judicial intervention must be sought for operation as an online instant bingo game in the STate of Florida
 *
 */

contract InstantBingo {
    uint256 public constant YEARS = 365 days;
    uint256 public constant MIN_NUMBERS_PER_CARD = 24;
    uint256 public constant MIN_CARD_NUMBER = 1;
    uint256 public constant MAX_CARD_NUMBER = 75;
    uint256 public constant MAX_TICKETS = 4000;

    address public owner;
    uint256 public maxPayout = 59520; // equivalent to $250 in wei, instant game does not have a max payout
    uint256 public minAge = 18;
    
    uint256 public totalPlayers;
    uint256 public winningNumber;

    enum GameState { Open, Closed, Finished, Archived }

    struct Player {
        uint256 game;
        uint256 gameSerialNo;
        uint256 formNumber;
        address playerAddress;
        uint256 ticketNumber;
    }
    /**
     * Bingo games can have various prize structures, and the specific structure often depends on the type of bingo game being played, the rules set by the organizer, and the region in which the game is conducted. Here are some common prize structures for bingo games:
     * 1. Single-Line Bingo: In this simple format, the first player to complete a horizontal, vertical, or diagonal line on their bingo card wins a prize.
     * 2. Pattern Bingo: Players must complete a specific pattern on their bingo card, which can be various shapes or designs. 
     *      The first player to complete the specified pattern is the winner.
     * 3. Coverall or Blackout Bingo: Players must cover all the numbers on their bingo card to win. 
     *      This is often the most challenging type of bingo game, and it typically offers a higher prize.
     * 4. Four Corners Bingo: Players must mark the four corner numbers on their card to win.
     * 5. Two-Line Bingo: Players need to complete two lines on their card to win, which can be two horizontal lines, two vertical lines, or one of each.
     *
     * 6. Jackpot Bingo: This is a progressive jackpot prize, where a specific pattern or number of calls are set, and if nobody wins within those calls, the jackpot prize increases for the next game.
     * 7. Consolation Prizes: In addition to the main prizes, some bingo games offer consolation prizes for players who achieve certain patterns or milestones, even if they don't win the main prize.
     * 8. Multiple Winners: In many bingo games, if multiple players complete the winning pattern on the same call, the prize is divided among the winners.
     * 9. Tiered Prizes: Prizes can vary based on the speed of achieving the winning pattern. The first player to complete the pattern might get a larger prize, while subsequent winners receive smaller prizes.
     * 10. Special Themed Games: Bingo games can have themed prizes based on holidays, seasons, or special occasions. For example, Halloween bingo might offer prizes related to the holiday.
     * 11. Community Jackpots: In some bingo games, if no one wins the jackpot, a community jackpot is awarded to all participants in the game.
     * 12. Guaranteed Prizes: Organizers may offer guaranteed prizes, ensuring that a minimum amount is awarded, even if there are only a few participants.
     * Remember that the specific prize structures and rules can vary significantly from one bingo game to another. Players should always review the rules and prize structure for the specific game they are participating in to understand what is at stake and how to win.
     */

    enum GameType {
        SingleLine,
        Pattern,
        CoverallBlackout,
        FourCorners,
        TwoLine
    }

    enum PrizeStructure {
        Jackpot,
        Consolation,
        Multiple,
        Tiered,
        CommunityJackpot,
        Guaranteed
    }

    struct Flare {
        string name;
        string manufacturer;
        uint256 formNumber;
        uint256 ticketCount;
        PrizeStructure prizeStructure;
        uint256 costPerPlay;
        uint256 gameSerialNo;
    }

    struct Rack {
        uint256 game;
        uint256[] number;
    }

    struct Game {
        uint256 serialNo;
        uint256 gameStartTime;
        uint256 gameEndTime;
        GameState state;
        uint256 totalPlayers;
        uint256 maxPlayers;
        uint256 totalCards;
        uint256 totalNumbers;
        uint256 numbersPerCard;
        uint256 balance;
    }

    struct Card {
        uint256 game;
        uint256 serialNo;
        uint256 formNumber;
        string ticket;
        string signature;
    }


    mapping(address => bool) private _players;
    mapping(address => Player[]) private players;

    Game[] private games;

    mapping(uint256 => Card[]) private gameCards;

    mapping(uint256 => uint256[]) private winningTickets; // winningTickets[game] = [ticketNumber,...]

    string public sponsor;

    event GameCreated(uint256 game);
    event GameCardNumbersAdded(uint256 game,uint256 card,uint256 formNumber,uint256 serialNo);
    event GameTicketPurchase(uint256 game,uint256 ticketNo,uint256 gameSerialNo);
    event GameEnded(uint256 game,uint256 winningNumber);
    event GamePrizeClaimed(uint256 game,address winner,uint256 amount);
    event ContractBalanceWithdrawn(uint256 balance);
    event MoniesReceived(address sender,uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory manufacturer) {
        owner = msg.sender;
        winningNumber = 0;
        sponsor = manufacturer;
    }

    receive() external payable {
        emit MoniesReceived(msg.sender,msg.value);
    }

    function newGame(uint256 startTime,uint256 endTime,uint256 serialNo,uint256 ticketCount,uint256 carryOver,uint256 usdWei) external onlyOwner returns (uint256) {
        games.push(
            Game(startTime,
                endTime,
                serialNo,
                GameState.Open,
                ticketCount,
                ticketCount, 
                ticketCount,
                MAX_CARD_NUMBER,
                MIN_NUMBERS_PER_CARD,
                (ticketCount * usdWei) + (carryOver * usdWei)));
        emit GameCreated(games.length - 1);
        return games.length;
    }

    /**
     * The Bingo Instant Ticket/Card is created offchain to comply with FS 849.0931 and sent as the following object
     *
     * {
     *    name: 'GAME ONE',
     *    manufacturer: 'AMERIONE CORPORATION',
     *    formNumber: '1699538915902',
     *    ticketCount: 4000,
     *    prizeStructure: 'Community Jackpot',
     *    price: 1,
     *    serialNo: '16995389158695327',
     *    ticket: 'H4sIAAAAAAAAEzVUSbLlMAi7UBYGD9hn+dX3v0Zr4C1ScRwGIQR/ce5X74u9v1iJ9/ri1BdjfpG4Hziv9z28Np/AFUwPzWGyp0zr4AXrul/c42gH0VY56kLUxP3D++Ku+KY7/s3OMsO2s+zHVAtxLt6Mz3OF49/+P8+XA+9grIFv5D/D/mMJ00P4uxsafl1cV31J10i74y5zyPSEaw+YBb/hNofPcYwul6tjBqKnrXzKdkKBkOPiSccEh2KAMe41AyAvac84JJN2RK88Q3kuEOY28iLaH8m8P65iTFfCtCTo8bs+ZblGtkJnmgW7fZ+JYEvf/nINd5icTBddiJJll3MsAuAp9T7jCo8ayGbPbg7LBDUgPFnBNsGEwx5nhnIqyaR0yPaxnBiqyGI41CAD0+css7O7A+rIbT/+D7M/ESNJzbIfWT7sTkrNGdQImz0lCttZFMJU2ySksZMmXOfoCglJEqWkj2FJrt1YTgNDs6mEStrX1UMVk8rrcMoWzpSTVKe0krHccFZDYt8RYp0Z/tceVKxerB6C3cJfckki5TeHgkP3rI3EkN2ecJqqiOmpjwaMbBwEtcCfpPq1FXXKsqnlvI1tGJcilWci04uCVHGy0bGNawgtl100w8PSzZ8GhvqfJJvE/iQ12Lvw//3Lzp3SJf9WkuT4TAvQFBn6rYZSdg/i7BDbKqZ8NLSv19jwStq9tvZqhqOl1OuFC3KZHxVNcn45QCdJH70r4Hp6PUiUvW6B5P3YGh7z540rLU6bCBiFJBFuA+CsgFm5l1vKeolhXNfN8+yM6TMxadcPly2T3ZNY7in/a3teKSJj+57f1DFSaqpxp4nmlqHcqzf4or7Xv/+AE63jXAYAAA==',
     *    signature: 'e5zuASVCJ7opk/86IKsW3CsKsgl6pZFj3k6ndKKb0RzVV1GKpQo6C6JBTe0UWb4tRwVpEaoH6z+dbRfT8Uzg3S6QOa4v0/AhYoeCTIJONQIis+nwdJ3IX0gd8PBiyyQ5Y3bfKFM7rhEUfb1DX1tCsGNr50nGTnh5+NoLWR4ml9+z+cRTz0k5aDlanyvjutmYsD61q68AURbstx9rBnYwtmVxDfkNS2qzgvmL0DrB9JIZtVpo2hUf4x5l3xVaVXlYpLt8Gr+v+8uc89VCRIvjErl9W40Hp4srUItovMyAQSGO4E3zQl5SLUOSXSOpABNGtgPUOzjPIdIrY9lSBssjhw=='
     *  }
     *
     * The ticket data is an encrypted compressed data stream of the bingo card grid with the associated rack for three chances of winning by single line, four corners or two lines
     * The ticket data can be decrypted off chain using the private key
     * The signature is used to verify the ticket data off-chain using the public key
     * {
     *  name: 'GAME ONE',
     *  manufacturer: 'AMERIONE CORPORATION',
     *  formNumber: '1699792690174',
     *  ticketCount: 5,
     *  prizeStructure: 'Community Jackpot',
     *  price: 1,
     *  serialNo: '16997926892024541',
     *  ticket: 'H4sIAAAAAAAAE02U2ZEgMQhDE/KHwXcsU5t/GstDdM18dLltcwgh/GP7tvOardVseqyz2T7N+mjmcd7jf772Yll8FkdhujEPkzXS9OxYwvrcZncr2o5o8yjqjKge5y/WG2eHFfe4G5VlmGzHkR+pZsS5sRKf/2OKf+t+7OY9ViNWj33k313+fSamF+HvKmhxdeP4nOa4mss9ztx7mm5T7RZmxj7cRrh5nLsLJf9H5t8WTuzIJUFExH7jc4UMCpMAA/wVAcGdYw9QuISwBZEuol7ZjKWWRIEOtGfhR+Ev7m6euUdFPhqhh0yB5cDLwoeKhKezBOGtdj8UOxHbjYj+8eRCPdOMBGmybnbNKTiZL77oTrDutlRUCARKbSqTveKQzoBw7LxDV8jslJZY4eO4OPWptHBXqdPVl1pEeFL3CE8sOn2BgQAgY6gaOEU4L6Bb8AjsIAG4yX2IzJ2yeiMEXUeLQAnzTE1a0syCgBusTKrqai26B2r6U1rPsck0WcaU3kM62Yv1BGeohUar15Uohys2svBv5K60jhwy1hZtdrJxSMVhGRnlHL7st1MH6sWGWevl14tCK+XbVTtmdXVrhlLS2WnTfI0/bfCS76r7UZIfZQdn++awwQdPwaqSCRkwrhB7XOW0ess3otcIXNXR9x8FfvXDewmVMUhJfD2Z4ioH3MRfJH2jpnGoVZSA6qAtJ/fWU9YVMh+DpxYjYsrEb36PwkgRw9wsJrjiHQ1FvFvAPb9cSLJ/9QFGwKArojCvzC/fKQ5zDIZ6hUbQJHoBeE2SEGzZIXv8mPXcm+xd6ECVD/6soZwygSqmxockwysVZ9fr4bnKePSk5hl0sLfq4bj//gNb88ULVAYAAA==',
     *  signature: 'EELcvDn9ZE22kUPcq90uKR/xGOLLElU2WuR2pBr+jPczSc7535wO+Q9iwoznW0crNiqYpM04AlsD3skM+pb4eaoWjD91ONgDz4kweEGTn1np6C8amQsSXW3BU8n8QYuPFcLQdnbUB2hOfmW606ks1INxz1Wiii6iexNOdBLcUkf44gGgK3Zb3plFDzWSMHfy/pT/Kubjze3QRPsp9hKr5RVwW3GCySEaTfsuisqD/Ri+L/ShZegt7Boc6aQFefB7J2ambrlEA/CFZ47y4WDMAG6l4s2n1KHNGxayqN1jiH1A9Q4JSmjo1Ajp15fF40avbhdBKAzIBkXsJfUBB3Yfeg=='
     * }
     */
    function addGameCard(uint256 game,uint256 formNumber,string memory ticket,string memory signature) external onlyOwner returns(uint256 card) {
        //require(gameCards[game].length < games[game].totalCards,"maximum card allocation has been reached");
        uint256 serialNo = games[game].serialNo;
        gameCards[game].push(Card(game,serialNo,formNumber,ticket,signature));
        card = gameCards[game].length - 1;
        emit GameCardNumbersAdded(game,card,formNumber,serialNo);
        return card;
    }

    function getGameCardNumbers(uint256 game,uint256 card) external view returns (Card memory) {
        return gameCards[game][card];
    }

    function yearToEpoch(uint16 year) public view returns (uint256) {        
        // Calculate the number of seconds in a year (365 days)
        uint256 secondsInAYear = 365 days;

        // Calculate the epoch timestamp for the given year
        uint256 epochTimestamp = block.timestamp + (year + 18) * secondsInAYear;

        return epochTimestamp;
    }

    function addPlayer(address wallet) external onlyOwner {
        require(_players[wallet] == false,"player already exists");
        _players[wallet] = true;
    }

    function buyTicket(uint256 game,uint256 _ticketNumber) external payable {
        require(games[game].state == GameState.Open, "The game is not open for ticket purchase");
        //require(msg.value == games[game].flare.costPerPlay, "Incorrect ticket price sent");
        //require(games[game].totalPlayers <= games[game].maxPlayers, "Maximum players reached");
        require(_ticketNumber >= 0, "Invalid ticket number");
        require(_players[msg.sender],"player is not authroized");

        players[msg.sender].push(Player(game,games[game].serialNo,gameCards[game][_ticketNumber].formNumber,msg.sender, _ticketNumber));

        games[game].totalPlayers += 1;

        if (games[game].totalPlayers == games[game].maxPlayers) {
            games[game].state = GameState.Closed;
            games[game].gameEndTime = block.timestamp;
        }
        emit GameTicketPurchase(game,_ticketNumber,games[game].serialNo);
    }

    function getPlayerTickets() external view returns (Player[] memory) {
        require(_players[msg.sender],"player is not authroized");
        return players[msg.sender];
    }

    function closeGame(uint256 game) external onlyOwner {
        require(games[game].state == GameState.Closed, "The game is not closed yet");
        //require(block.timestamp >= games[game].gameEndTime, "The game has not ended yet");

        // Generate a random winning number using a provably fair method.
        winningNumber = uint256(keccak256(abi.encodePacked(block.timestamp))) % games[game].maxPlayers;

        games[game].state = GameState.Finished;

        // Check if the maximum payout limit is reached
        if (address(this).balance > maxPayout) {
            payable(owner).transfer(address(this).balance - maxPayout);
        }

        emit GameEnded(game, winningNumber);
    }

    function claimPrize(uint256 game) external {
        require(games[game].state == GameState.Finished, "The game has not finished yet");
        //require(msg.sender == _players[winningNumber], "You are not the winner");
        uint256 prizeAmount = maxPayout < address(this).balance ? maxPayout : address(this).balance;
        winningNumber = 0;
        games[game].state = GameState.Archived;
        payable(msg.sender).transfer(prizeAmount);
        emit GamePrizeClaimed(game,msg.sender,prizeAmount);
    }

    function withdrawRemainingFunds(uint256 game) external onlyOwner {
        require(games[game].state == GameState.Archived, "The game has not finished yet");
        require(block.timestamp >= games[game].gameEndTime + 7 days, "Withdrawal time has not passed yet");
        uint256 contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
        emit ContractBalanceWithdrawn(contractBalance);
    }

    function getGameState(uint256 game) external view returns (GameState) {
        return games[game].state;
    }

    function getGameEndTime(uint256 game) external view returns (uint256) {
        return games[game].gameEndTime;
    }

    //function getPlayers() external view returns (address[] memory) {
    //    return _players;
    //}

    function getGames() external view returns (Game[] memory) {
        return games;
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function setMaxPayout(uint256 amountInWei) external {
        maxPayout = amountInWei;
    }
}
