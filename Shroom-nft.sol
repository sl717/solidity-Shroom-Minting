// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Shrooms is ERC721Enumerable, Ownable {

  using Strings for uint256;

  string _baseTokenURI;
  address private admin = 0x27DF8590c11F2e5E7B0d0e00Ac8f39aFE0BA127E;
  uint256 public constant MAX_ENTRIES = 2500;

  uint[5] private PRICES =  [ 35 ether, 50 ether, 75 ether, 100 ether, 0 ether ];
  uint8[3] private MAX_BUYABLE = [3, 5, 1];
  uint8 private currentPriceId = 0;
  mapping (address=>bool) public whitelisted;
  mapping (address=>uint256) freeminted;

  enum STAGES { PRESALE, PUBLICSALE, FREESALE }
  STAGES stage = STAGES.PRESALE;

  uint256 public totalMinted;
  uint256 public sold;

  uint256[MAX_ENTRIES] internal availableIds;

  constructor(string memory baseURI) 
      ERC721("Fantom Shrooms", "FTM.Shrooms")  {
      setBaseURI(baseURI);
      for (uint8 i = 0; i < 250; i++)
        _mint(admin, _getNewId(i));
      totalMinted = 250;
      sold = 0;
      // whitelisted[0x2A0ecFb6364787F2B80A05C57B6A827Baf59b164] = true;
  }

  function _getNewId(uint256 _totalMinted) internal returns(uint256 value) {
    uint256 remaining = MAX_ENTRIES - _totalMinted;
    uint256 rand = uint256(keccak256(abi.encodePacked(msg.sender, block.difficulty, block.timestamp, remaining))) % remaining;
    value = 0;
    // if array value exists, use, otherwise, use generated random value
    if (availableIds[rand] != 0)
      value = availableIds[rand];
    else
      value = rand;
    // store remaining - 1 in used ID to create mapping
    if (availableIds[remaining - 1] == 0)
      availableIds[rand] = remaining - 1;
    else
      availableIds[rand] = availableIds[remaining - 1];
    value += 1;
  } 

  function mint(uint256 _amount) external payable {
    require(_amount + totalMinted <= MAX_ENTRIES, 'Amount exceed');
    if (stage == STAGES.PRESALE) {
      require(whitelisted[msg.sender], 'Only whitelisted address can mint first 250 NFTs');
      require(balanceOf(msg.sender)+_amount <= MAX_BUYABLE[0], 'BUYABLE LIMIT EXCEED');
    }
    else if (stage == STAGES.PUBLICSALE) {
      require(balanceOf(msg.sender)+_amount <= MAX_BUYABLE[1], 'BUYABLE LIMIT EXCEED');
      require(sold + _amount <= 2000, 'Public sale amount exceed');
    }
    else if (stage == STAGES.FREESALE) {
      require(balanceOf(msg.sender) > 0, 'Only a holder can mint this NFT');
      require(freeminted[msg.sender]+_amount <= MAX_BUYABLE[2], 'FREE MINT LIMIT EXCEED');
      freeminted[msg.sender] += _amount;
    }
    uint256 amountForNextPrice = 500 - (sold%500);
    uint256 estimatedPrice = 0;
    if (_amount > amountForNextPrice)
      estimatedPrice = PRICES[currentPriceId] * amountForNextPrice + PRICES[currentPriceId+1] * (_amount-amountForNextPrice);
    else
      estimatedPrice = PRICES[currentPriceId] * _amount;
    require(msg.value >= estimatedPrice, "FTM.Shrooms: incorrect price");
    payable(admin).transfer(address(this).balance);
    for (uint8 i = 0; i < _amount; i++)
      _mint(msg.sender, _getNewId(totalMinted + i));
    if (sold < 250 && sold+_amount >= 250)
      stage = STAGES.PUBLICSALE;
    else if (sold < 2000 && sold+_amount >= 2000)
      stage = STAGES.FREESALE;
    totalMinted += _amount;
    sold += _amount;
    if (_amount >= amountForNextPrice)
      currentPriceId += 1;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function getCurrentPrice() external view returns (uint256) {
    return PRICES[currentPriceId];
  }

  function getCurrentStage() external view returns (STAGES) {
    return stage;
  }

  function toggleWhitelistedAddress(address tokenAddress) external onlyOwner {
    if (whitelisted[tokenAddress])
      whitelisted[tokenAddress] = false;
    else
      whitelisted[tokenAddress] = true;
  }
}