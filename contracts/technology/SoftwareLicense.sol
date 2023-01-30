// SPDX-License-Identifier: CC-BY-4.0
pragma solidity >=0.4.22 <0.9.0;

import "../common/Version.sol";
import "../common/Frozen.sol";
import "../common/ERC721Enumerable.sol";
import "../libs/Strings.sol";

contract SoftwareLicense is Version, Frozen, ERC721Enumerable, ReentrancyGuard  {
    using Strings for uint256;

    uint256 public maxNFT = 10000;
    uint256 public minPrice  = 10**18;
    uint256 public maxBatch  = 50 * (10**18);
    address payable private manager;
    uint256 mintdate = 13949060;

    constructor() ERC721("SoftwareLicense", "SoftwareLicense") {
      manager = payable(msg.sender);
    }




    function getNFTzBelongingToOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 numNFT = balanceOf(_owner);
        if (numNFT == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](numNFT);
            for (uint256 i = 0; i < numNFT; i++) {
                result[i] = tokenOfOwnerByIndex(_owner, i);
            }
            return result;
        }
    }


    string private _baseTokenURI = './SoftwareLicense.json'; // https://gateway.pinata.cloud/ipfs/QmeVk1pmqk2vKoMiNmEhyax6f2ybQD2XQivw6MAuPmxYdm

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory base = _baseTokenURI;
        string memory _tokenURI = Strings.toString(_tokenId);
        //string memory ending = ".json";
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        return string(abi.encodePacked(base));
    }

    function setPrice(uint256 newPrice) public okOwner() {
        minPrice = newPrice;
    }

    function setBaseURI(string memory baseURI) external okOwner {
        _baseTokenURI = baseURI;
    }

    function withdraw(uint256 _wamount) public okOwner {
        //uint balance = address(this).balance; <- this code lines calculate all amount of contract and send this amount entirely to manager
        payable(msg.sender).transfer(_wamount);
    }


    function getEthBalance() public view returns(uint) {
        return address(this).balance;
    }


    function depositer() public payable returns(uint256){
        require(msg.sender == manager,"only manager can reach  here");
        return address(this).balance;
    }

    function _beforeTokenTransfer(address from,address to,uint256 tokenId)
        internal
        virtual
        override(ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    function batchTransfer(address recipient, uint256[] memory tokenIds) public {
       for (uint256 index; index < tokenIds.length; index++) {
           transferFrom(msg.sender, recipient, tokenIds[index]);
       }
    }

    function fmint() public okOwner() {
        for (uint256 i = 0; i < 50; i++) {
            if(totalSupply() + 1 <= maxNFT) {
                newTokenId += 1;
                _safeMint(msg.sender, newTokenId);
                uint balance = address(this).balance;
                payable(manager).transfer(balance);
            } else {
                revert();
            }
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}