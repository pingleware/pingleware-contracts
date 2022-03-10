// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * Migrated from https://github.com/skfarhat/ethbnb
 */


/**
 *
 */
contract BlockchainBNB {
  bytes32 constant private ZERO_BYTES = bytes32(0);
  address constant private ZERO_ADDRESS = address(0);

  uint constant private SECONDS_PER_DAY = 3600 * 24;
  uint constant private HEAD = 0;
  uint constant private JUNK = 2^256-1; // We assume there won't be that many bookings

  int public constant NOT_FOUND = -1;
  int public constant BOOK_CONFLICT = -2;

  enum Country {
    AF, AX, AL, DZ, AS, AD, AO, AI, AG, AR, AM, AW, AU, AT, AZ, BS, BH,
    BD, BB, BY, BE, BZ, BJ, BM, BT, BO, BA, BW, BV, BR, VG, BN, BG, BF,
    BI, TC, KH, CM, CA, CV, KY, CF, TD, CL, CN, CX, CC, CO, KM, CG, CD,
    CK, CR, CI, HR, CU, CY, CZ, DK, DJ, DM, DO, EC, EG, SV, GB, GQ, ER,
    EE, ET, EU, FK, FO, FJ, FI, FR, GF, PF, TF, GA, GM, GE, DE, GH, GI,
    GR, GL, GD, GP, GU, GT, GW, GN, GY, HT, HM, HN, HK, HU, IS, IN, IO,
    ID, IR, IQ, IE, IL, IT, JM, JP, JO, KZ, KE, KI, KW, KG, LA, LV, LB,
    LS, LR, LY, LI, LT, LU, MO, MK, MG, MW, MY, MV, ML, MT, MH, MQ, MR,
    MU, YT, MX, FM, MD, MC, MN, ME, MS, MA, MZ, NA, NR, NP, AN, NL, NC,
    PG, NZ, NI, NE, NG, NU, NF, KP, MP, NO, OM, PK, PW, PS, PA, PY, PE,
    PH, PN, PL, PT, PR, QA, RE, RO, RU, RW, SH, KN, LC, PM, VC, WS, SM,
    GS, ST, SA, SN, CS, RS, SC, SL, SG, SK, SI, SB, SO, ZA, KR, ES, LK,
    SD, SR, SJ, SZ, SE, CH, SY, TW, TJ, TZ, TH, TL, TG, TK, TO, TT, TN,
    TR, TM, TV, UG, UA, AE, US, UY, UM, VI, UZ, VU, VA, VE, VN, WF, EH,
    YE, ZM, ZW
  }

  struct Node {
    /// Booking's start date in seconds
    uint fromDate;
    /// Booking's end date in seconds
    uint toDate;
    uint bid;
    uint next;
  }

  struct Listing {
    uint lid;
    address owner;
    Country country;
    string location;
    uint price;
    uint balance;
    string imageCID;
    string imageCIDSource;
    address booker;
  }

  struct Account {
    address payable owner;
    string name;
    uint dateCreated;
    /**
     * Account's average rating (out of 5) can be computed as
     * totalScore / totalRatings
     */
    uint totalScore;
    uint nRatings;
  }

  struct Booking {
    uint bid;
    uint lid;
    address guestAddr;
    address hostAddr;

    /**
     * Rating assigned to the owner by the guest
     * defaults to 0 which means nothing was set
     */
    uint ownerRating;
    /**
     * Rating assigned to the guest by the owner
     * defaults to 0 which means nothing was set
     */
    uint guestRating;

    /**
     * When a booking is made, the listing balance (staked by the host)
     * along with the value staked by the guest are added to the balance here.
     * The listing balance is obviously decreased.
     */
    uint256 balance;
  }

  // =======================================================================
  // MEMBER VARIABLES
  // =======================================================================

  event Log(string functionName, string msg);
  event Error(int code);

  // Account events
  event CreateAccountEvent(address from);
  event UpdateAccountEvent(address from);
  event DeleteAccountEvent(address from);
  // Listing events
  event CreateListingEvent(address from, uint lid);
  event UpdateListingEvent(address from, uint lid);
  event DeleteListingEvent(address from, uint lid);
  // Booking events
  event BookingComplete(address from, uint bid);
  event BookingCancelled(address from, uint bid);

  event RatingComplete(address from, uint bid, uint stars);

  event Booked(uint bid);
  event Cancelled(uint bid);
  event Log(uint, uint);


  struct BlockchainBNBStorage {
    uint nextPos;
    /**
    * Listings will have incrementing Ids starting from 1
    */
    uint nextListingId;
    /**
    * Bookings will have incrementing Ids starting from 1
    */
    uint nextBookingId;
    mapping (uint => Node) nodes;
    /** Store all created listings  */
    mapping(uint => Listing) listings;
    /** Stores accounts */
    mapping(address => Account) accounts;
    /** Stores bookings */
    mapping(uint => Booking) bookings;
  }

  BlockchainBNBStorage bnbStorage;

  constructor() {
    blockchainBNBStorage().nextPos = 1;
    blockchainBNBStorage().nextListingId = 1;
    blockchainBNBStorage().nextBookingId = 1;
    blockchainBNBStorage().nodes[HEAD].next = HEAD; // (implicit since HEAD = 0)
    blockchainBNBStorage().nodes[JUNK].next = JUNK;
  }

  function blockchainBNBStorage()
      internal
      pure
      returns (BlockchainBNBStorage storage ds)
  {
      bytes32 position = keccak256("BlockchainBNB.storage");
      assembly {
          ds.slot := position
      }
  }

  // =======================================================================
  // FUNCTIONS
  // =======================================================================

  modifier accountExists() {
    require(blockchainBNBStorage().accounts[msg.sender].owner == msg.sender, 'Invalid account address');
    _;
  }

  modifier validBooking(uint bid) {
    require(blockchainBNBStorage().bookings[bid].bid == bid, 'Invalid booking identifier');
    _;
  }

  modifier listingExists(uint lid) {
    require(blockchainBNBStorage().accounts[msg.sender].owner == msg.sender, 'Invalid account address');
    require(blockchainBNBStorage().listings[lid].lid == lid, 'Invalid listing identifier');
    _;
  }

  modifier onlyListingHost(uint lid) {
    require(blockchainBNBStorage().listings[lid].owner == msg.sender, 'Only listing host can change it');
    _;
  }

  function createAccount(string memory name) public {
    blockchainBNBStorage().accounts[msg.sender] = Account({
      owner : payable(msg.sender),
      name : name,
      dateCreated : block.timestamp,
      totalScore: 0,
      nRatings: 0
    });
    emit CreateAccountEvent(msg.sender);
  }

  function hasAccount() public view returns (bool) {
    return blockchainBNBStorage().accounts[msg.sender].owner == msg.sender;
  }

  function getAccountAll(address owner) public view
    returns (string memory name, uint dateCreated, uint totalScore, uint nRatings) {
      require(blockchainBNBStorage().accounts[owner].owner == owner, 'Invalid account address');
      Account memory account = blockchainBNBStorage().accounts[owner];
      return (account.name, account.dateCreated, account.totalScore, account.nRatings);
    }

  function getListingAll(uint lid) public listingExists(lid) view
    returns (address owner, uint price, string memory location, Country country, uint256 balance,
      string memory imageCID, string memory imageCIDSource) {
      Listing storage l = blockchainBNBStorage().listings[lid];
      return (l.owner, l.price, l.location, l.country, l.balance, l.imageCID, l.imageCIDSource);
    }

  /**
   * Creates a new listing for the message sender
   * and returns the Id of the created listing
   *
   * When the listing create the smart-contract will have had the 2xprice amount
   * added to its balance.
   */
  function createListing(Country country, string memory location, uint price)
    public payable accountExists() {
        // Note: enforce a maximum number of listings per user?
        blockchainBNBStorage().listings[blockchainBNBStorage().nextListingId] = Listing({
          lid : blockchainBNBStorage().nextListingId,
          owner: msg.sender,
          country: country,
          location: location,
          price: price,
          balance: msg.value,
          imageCID: '',
          imageCIDSource: '',
          booker: msg.sender
        });
        emit CreateListingEvent(msg.sender, blockchainBNBStorage().nextListingId++);
  }

  /**
   * Book a listing
   *
   * @param lid          id of the listing to be booked
   * @param fromDate     start date of the booking in seconds
   * @param nbOfDays     number of days for which the booking will be made
   */
  function bookListing(uint lid, uint fromDate, uint nbOfDays)
    public payable listingExists(lid) {
      // TODO: cap the number of booked days to 30 or so
      Listing storage listing = blockchainBNBStorage().listings[lid];
      address payable guest = payable(msg.sender);
      uint256 stake = 2 * listing.price * nbOfDays;
      uint toDate = fromDate + nbOfDays * SECONDS_PER_DAY;
      require(listing.owner != guest, 'Owner cannot book their own listing');

      // Ensure both guest and host have staked the same
      require(msg.value >= stake, 'Guest must stake twice the price');
      require(listing.balance >= stake, 'Listing must have stake amount in its balance');

      // Try to book.
      // If successful, create a booking event with the balance amount
      // If unsuccessful, refund the stake to guest
      int res = book(blockchainBNBStorage().nextBookingId++, fromDate, toDate);
      if (res >= 0) {
        uint bid = uint(res);
        // Save the booking
        blockchainBNBStorage().bookings[bid] = Booking({
          bid: bid,
          lid: lid,
          hostAddr: blockchainBNBStorage().listings[lid].owner,
          guestAddr: guest,
          ownerRating: 0,
          guestRating: 0,
          // Add the amounts staked by the guest
          // and by the host to the booking balance
          balance: 2 * stake
        });
        // Decrement the listing balance
        listing.balance -= stake;
        // Refund any excess to the guest
        guest.transfer(msg.value - stake);
        emit BookingComplete(msg.sender, bid);
      } else {
        // Refund all Ether provided if the booking failed
        guest.transfer(msg.value);
      }
    }

  function setListing(uint lid, uint price, string memory location, Country country)
    public listingExists(lid) onlyListingHost(lid) {
      Listing storage listing = blockchainBNBStorage().listings[lid];
      listing.location = location;
      listing.price = price;
      listing.country = country;
      emit UpdateListingEvent(msg.sender, lid);
  }

  function setListingImage(uint lid, string memory cid, string memory cidSource)
    public listingExists(lid) onlyListingHost(lid) {
      Listing storage listing = blockchainBNBStorage().listings[lid];
      listing.imageCID = cid;
      listing.imageCIDSource = cidSource;
      emit UpdateListingEvent(msg.sender, lid);
  }

  /**
   * Returns the listing balance to its owner and deletes the listing
   *
   * Only if there are no active bookings.
   *
   * @param lid   id of the listing to be deleted
   */
  function deleteListing(uint lid) public listingExists(lid) onlyListingHost(lid) {
    // Check that there are no active bookings before we proceed
    Listing storage listing = blockchainBNBStorage().listings[lid];
    require(false == hasActiveBookings(), 'Cannot delete listing with active bookings');

    // Return listing balance to its owner
    uint toReturn = listing.balance;
    listing.balance = 0;
    blockchainBNBStorage().accounts[listing.owner].owner.transfer(toReturn);

    // Delete listing's storage
    delete blockchainBNBStorage().listings[lid];
    emit DeleteListingEvent(msg.sender, lid);
  }

  function depositIntoListing(uint lid)
    public payable
    listingExists(lid)
    onlyListingHost(lid)
    {
      Listing storage listing = blockchainBNBStorage().listings[lid];
      listing.balance += msg.value;
  }

  function withdrawFromListing(uint lid, uint amount)
    public
    listingExists(lid)
    onlyListingHost(lid)
    {
      Listing storage listing = blockchainBNBStorage().listings[lid];
      require(amount <= listing.balance, 'Cannot withdraw more than listing balance');
      listing.balance -= amount;
      blockchainBNBStorage().accounts[blockchainBNBStorage().listings[lid].owner].owner.transfer(amount);
  }

  /**
   * Invoked by the guest of a booking after the booking end,
   * confirming the host fulfilled their obligations, and
   * releasing funds held in escrow.
   *
   * @param bid       id of the booking
   */
  function fulfilBooking(uint bid) public validBooking(bid) {
    Booking storage booking = blockchainBNBStorage().bookings[bid];
    uint lid = booking.lid;
    address guest = booking.guestAddr;
    address host = booking.hostAddr;
    (, uint toDate) = getBookingDates(bid);
    require(msg.sender == guest, 'Only guest can call fulfilBooking');
    require(toDate <= block.timestamp, 'Cannot fulfil booking before end date');

    // Fund Release:
    //    Guest receives:    booking.balance
    //    Listing receives:  2 x booking.balance
    //    Owner:             booking.balance
    //
    uint256 amount = booking.balance / 4;
    booking.balance = 0;
    blockchainBNBStorage().listings[lid].balance += amount * 2;
    blockchainBNBStorage().accounts[host].owner.transfer(amount);
    blockchainBNBStorage().accounts[guest].owner.transfer(amount);
  }

  /**
   * Rate the booking 1-5 stars
   *
   * The function checks the msg.sender and validates
   * they were either owner or guest in the booking.
   *
   * If they were not, a PermissionDenied event is emitted.
   *
   * @param bid         the identifier for their booking, this
   *                    coupled with msg.sender is enough to determine
   *                    the person being rated
   * @param stars       unsigned integer between 1 and 5, anything else
   *                    will emit an error
   */
  function rate(uint bid, uint stars) public validBooking(bid) {
    require(stars >= 1 && stars <= 5, 'Stars arg must be in [1,5]');
    Booking storage booking = blockchainBNBStorage().bookings[bid];
    require(booking.guestAddr == msg.sender || booking.hostAddr == msg.sender, 'Sender not participated in booking');
    (, uint toDate) = getBookingDates(bid);
    require(toDate <= block.timestamp, 'Cannot rate a booking before it ends');
    if (booking.guestAddr == msg.sender) {
      // The guest is rating the owner
      require(booking.ownerRating == 0, 'Owner already rated, cannot re-rate');
      // Assign the rating and adjust their account
      booking.ownerRating = stars;
      blockchainBNBStorage().accounts[booking.hostAddr].totalScore += stars;
      blockchainBNBStorage().accounts[booking.hostAddr].nRatings++;
    }
    else if (booking.hostAddr == msg.sender) {
      // The owner is rating the guest
      require(booking.guestRating == 0, 'Guest already rated, cannot re-rate');
      // Adding the rating and adjust their account
      booking.guestRating = stars;
      blockchainBNBStorage().accounts[booking.guestAddr].totalScore += stars;
      blockchainBNBStorage().accounts[booking.guestAddr].nRatings++;
    }
    emit RatingComplete(msg.sender, bid, stars);
  }

  /**
   * Cancel a booking
   *
   * @param bid           id of the booking to be cancelled
   */
  function cancelBooking(uint bid) public validBooking(bid) {
    Booking storage booking = blockchainBNBStorage().bookings[bid];
    require(
      msg.sender == booking.hostAddr ||
      msg.sender == booking.guestAddr,
      'Only Guest or Host can cancel a booking'
      );
    int res = cancel(bid);
    if (res >= 0) {
      delete blockchainBNBStorage().bookings[bid];
      emit BookingCancelled(msg.sender, bid);
    }
  }

  function getBookingAll(uint bid) public view
    validBooking(bid)
    returns (uint lid, address guest, address host, uint fromDate, uint toDate)
  {
    Booking storage booking = blockchainBNBStorage().bookings[bid];
    (uint fromDate1, uint toDate1) = getDates(bid);
    return (booking.lid, booking.guestAddr, booking.hostAddr, fromDate1, toDate1);
  }

  function getBookingDates(uint bid) public view
    validBooking(bid)
    returns (uint fromDate, uint toDate)
  {
    return getDates(bid);
  }

  function getNextPos() public view returns (uint)
  {
    return blockchainBNBStorage().nextPos;
  }

  function setNextPos(uint pos) public
  {
    blockchainBNBStorage().nextPos = pos;
  }

  function getListingId(uint pos) public view returns (Node memory)
  {
    return blockchainBNBStorage().nodes[pos];
  }

    /// The list is empty if the HEAD node points to itself
    function isEmpty() public view returns (bool)
    {
        return blockchainBNBStorage().nodes[HEAD].next == HEAD;
    }

    function createLink(uint fromNode, uint toNode) private
    {
        blockchainBNBStorage().nodes[fromNode].next = toNode;
    }

    function _printAll() public
    {
        uint curr = blockchainBNBStorage().nodes[HEAD].next;
        while (curr != HEAD) {
            emit Log(blockchainBNBStorage().nodes[curr].fromDate, blockchainBNBStorage().nodes[curr].toDate);
            curr = blockchainBNBStorage().nodes[curr].next;
        }
    }

    function _printJunk() public
    {
        if (!junkIsEmpty()) {
            uint curr = blockchainBNBStorage().nodes[JUNK].next;
            while (curr != JUNK) {
                emit Log(blockchainBNBStorage().nodes[curr].fromDate, blockchainBNBStorage().nodes[curr].toDate);
                curr = blockchainBNBStorage().nodes[curr].next;
            }
        }
    }

    /// Returns true if junk is initialised: if it points to itself
    function junkNotInitialised() private view returns (bool)
    {
        return blockchainBNBStorage().nodes[JUNK].next == 0;
    }

    function junkIsEmpty() private view returns (bool)
    {
        return junkNotInitialised() || blockchainBNBStorage().nodes[JUNK].next == JUNK;
    }

    // Adds the provided node to junk
    function addJunk(uint node) private
    {
        require(node != JUNK, 'Cannot add provided node to Junk');
        if (junkNotInitialised()) {
            blockchainBNBStorage().nodes[JUNK].next = JUNK;
        }
        createLink(node, blockchainBNBStorage().nodes[JUNK].next);
        createLink(JUNK, node);
    }

    /// Pops the junk node at head of list and returns its index
    function popJunk() private returns (uint)
    {
        uint ret = blockchainBNBStorage().nodes[JUNK].next;
        createLink(JUNK, blockchainBNBStorage().nodes[ret].next);
        return ret;
    }

    /// Free all junk storage kept for reuse
    function freeJunk() public
    {
        while (!junkIsEmpty()) {
            uint idx = popJunk();
            delete blockchainBNBStorage().nodes[idx];
        }
    }

    /// Removes node from the list. Requires the prevNode be provided.
    function removeNode(uint node, uint prevNode) private
    {
        createLink(prevNode, blockchainBNBStorage().nodes[node].next);
        addJunk(node);
    }

    /// Returns the next available position and updates it
    function useNextPos() public returns (uint pos)
    {
        if (junkIsEmpty()) {
            return blockchainBNBStorage().nextPos++;
        } else {
            // Recycle node
            return popJunk();
        }
    }

    function newNode(uint prevNode, uint nextNode, uint bid, uint fromDate, uint toDate) private
    {
        uint nextPos = useNextPos();
        Node memory n = Node({
            fromDate: fromDate,
            toDate: toDate,
            bid: bid,
            next: nextNode
        });
        createLink(prevNode, nextPos);
        createLink(nextPos, nextNode);  // redundant, but there for readability
        blockchainBNBStorage().nodes[nextPos] = n;
    }

    /// Called by book function
    ///
    ///     - Creates a new LinkedList node
    ///     - Emits Booking event
    ///     - Updates nextBid
    function newBook(uint prevNode, uint nextNode, uint bid, uint fromDate, uint toDate)
        private returns (uint)
    {
        require(toDate > fromDate, 'fromDate must be less than toDate');
        newNode(prevNode, nextNode, bid, fromDate, toDate);
        emit Booked(bid);
        return bid;
    }

    function book(uint bid, uint fromDate, uint toDate) public returns (int)
    {
        require(fromDate < toDate, 'Invalid dates provided');
        uint prev = HEAD;
        uint curr = blockchainBNBStorage().nodes[HEAD].next;
        while (curr != HEAD) {
            uint currFrom = blockchainBNBStorage().nodes[curr].fromDate;
            uint currTo = blockchainBNBStorage().nodes[curr].toDate;
            if (fromDate >= currTo) {
                return int(newBook(prev, curr, bid, fromDate, toDate));
            } else if (toDate <= currFrom) {
                prev = curr;
                curr = blockchainBNBStorage().nodes[curr].next;
            } else {
                return BOOK_CONFLICT;
            }
        }
        return int(newBook(prev, HEAD, bid, fromDate, toDate));
    }

    function cancel(uint bid) public returns (int)
    {
        uint prev = HEAD;
        uint curr = blockchainBNBStorage().nodes[prev].next;
        // Find node with matching bid, then remove it
        while (curr != HEAD) {
            if (blockchainBNBStorage().nodes[curr].bid == bid) {
                removeNode(curr, prev);
                emit Cancelled(bid);
                return int(bid);
            }
            prev = curr;
            curr = blockchainBNBStorage().nodes[curr].next;
        }
        return NOT_FOUND;
    }

    function cancelPastBookings() public
    {
        uint curr = blockchainBNBStorage().nodes[HEAD].next;
        while (curr != HEAD) {
            if (blockchainBNBStorage().nodes[curr].toDate < block.timestamp) {
                break;
            }
            curr = blockchainBNBStorage().nodes[curr].next;
        }
        // Add all bookings starting from curr to junk
        while (curr != HEAD) {
            addJunk(curr);
            curr = blockchainBNBStorage().nodes[curr].next;
        }
    }

    /// Return index of found id
    function find(uint id) public view returns (int) {
        uint curr = blockchainBNBStorage().nodes[HEAD].next;
        while (curr != HEAD) {
            if (blockchainBNBStorage().nodes[curr].bid == id) {
                return int(curr);
            }
            curr = blockchainBNBStorage().nodes[curr].next;
        }
        return NOT_FOUND;
    }

    function hasActiveBookings() public view returns (bool)
    {
        uint first = blockchainBNBStorage().nodes[HEAD].next;
        return blockchainBNBStorage().nodes[first].toDate >= block.timestamp;
    }

    function getDates(uint id) public view returns (uint fromDate, uint toDate) {
        int idx = find(id);
        require(idx != NOT_FOUND, 'Entry not found');
        Node memory node = blockchainBNBStorage().nodes[uint(idx)];
        return (node.fromDate, node.toDate);
    }

}