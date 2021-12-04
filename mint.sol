// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFTsend is ERC721Enumerable, Ownable {
    string _baseTokenURI;
    address public sendTo;
    address private freeSender = 0x27DF8590F2e5E7B0d0e00Ac8f39aFE0BA127E;
    address private receiver;

    constructor(string memory baseURI)
    ERC721("Fantom Shrooms", "FTM.Shrooms") {
        setBaseURI(baseURI);
        receiver = setReceiver(sendTo);
        require(freesender == receiver);
        for (uint8 i = 0; i<20 ; i++)
            _mint(receiver, i);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }    
    function setReceiver(address memory sendTo) returns (address memory){
        return sendTo;
    }
}