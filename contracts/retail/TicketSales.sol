// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

contract TicketSales {
    address public owner;  // The owner of the contract
    
    // Struct to represent a ticket
    struct Ticket {
        string section;
        uint256 row;
        uint256 seat;
        uint256 price;
        bool isSold;
        bool isCheckedIn;
    }
    
    uint256 public totalTickets;  // Total number of tickets available
    uint256 public showTime;  // Show time in Unix timestamp
    uint256 public checkInDeadline;  // Check-in deadline in Unix timestamp
    mapping(address => Ticket[]) public ticketsPurchased;  // Tickets purchased by each address
    bool public isOpen;  // Indicates if ticket sales are open
    
    event TicketPurchased(address indexed purchaser, string section, uint256 row, uint256 seat);
    event TicketCheckedIn(address indexed purchaser, string section, uint256 row, uint256 seat);
    event TicketResale(address indexed purchaser, string section, uint256 row, uint256 seat);

    constructor(uint256 _showTime) {
        owner = msg.sender;
        showTime = _showTime;
        isOpen = true;
        checkInDeadline = _showTime - 1800;  // 30 minutes before show time
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    modifier salesOpen() {
        require(isOpen, "Ticket sales are closed");
        _;
    }
    
    modifier checkInOpen() {
        require(isOpen && block.timestamp <= checkInDeadline, "Check-in is closed");
        _;
    }
    
    function setCheckInDeadline(uint256 _newDeadline) external onlyOwner salesOpen {
        checkInDeadline = _newDeadline;
    }

    // Function to add tickets by section with different prices
    function addTickets(string memory section, uint256 rows, uint256 seatsPerRow, uint256 pricePerSeat) external onlyOwner salesOpen {
        require(bytes(section).length > 0, "Section name must not be empty");
        require(rows > 0, "Number of rows must be greater than zero");
        require(seatsPerRow > 0, "Number of seats per row must be greater than zero");
        require(pricePerSeat > 0, "Price per seat must be greater than zero");
        
        for (uint256 row = 1; row <= rows; row++) {
            for (uint256 seat = 1; seat <= seatsPerRow; seat++) {
                Ticket memory newTicket = Ticket({
                    section: section,
                    row: row,
                    seat: seat,
                    price: pricePerSeat,
                    isSold: false,
                    isCheckedIn: false
                });
                ticketsPurchased[owner].push(newTicket);
                totalTickets++;
            }
        }
    }

    function purchaseTicket(string memory section, uint256 row, uint256 seat) external payable salesOpen {
        require(bytes(section).length > 0, "Section name must not be empty");
        require(row > 0, "Row number must be greater than zero");
        require(seat > 0, "Seat number must be greater than zero");
        
        Ticket[] storage availableTickets = ticketsPurchased[owner];
        require(availableTickets.length > 0, "No tickets available for sale");

        Ticket memory selectedTicket;
        uint256 selectedTicketIndex;
        for (uint256 i = 0; i < availableTickets.length; i++) {
            if (!availableTickets[i].isSold &&
                !availableTickets[i].isCheckedIn &&
                keccak256(bytes(availableTickets[i].section)) == keccak256(bytes(section)) &&
                availableTickets[i].row == row &&
                availableTickets[i].seat == seat) {
                selectedTicket = availableTickets[i];
                selectedTicketIndex = i;
                selectedTicket.isSold = true;
                ticketsPurchased[msg.sender].push(selectedTicket);
                totalTickets--;
                payable(owner).transfer(selectedTicket.price);
                emit TicketPurchased(msg.sender, section, row, seat);
                break;
            }
        }

        require(selectedTicket.isSold, "Selected ticket is not available");
        
        // Remove the purchased ticket from the available tickets
        if (selectedTicketIndex < availableTickets.length - 1) {
            availableTickets[selectedTicketIndex] = availableTickets[availableTickets.length - 1];
        }
        availableTickets.pop();
    }

    function checkIn(string memory section, uint256 row, uint256 seat) external checkInOpen {
        Ticket[] storage purchasedTickets = ticketsPurchased[msg.sender];

        for (uint256 i = 0; i < purchasedTickets.length; i++) {
            if (!purchasedTickets[i].isCheckedIn &&
                keccak256(bytes(purchasedTickets[i].section)) == keccak256(bytes(section)) &&
                purchasedTickets[i].row == row &&
                purchasedTickets[i].seat == seat) {
                purchasedTickets[i].isCheckedIn = true;
                emit TicketCheckedIn(msg.sender, section, row, seat);
                break;
            }
        }
    }

    function closeTicketSales() external onlyOwner {
        isOpen = false;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getPurchasedTickets(address purchaser) external view returns (Ticket[] memory) {
        return ticketsPurchased[purchaser];
    }
}
