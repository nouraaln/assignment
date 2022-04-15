// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
 
import "https://github.com/0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/0xcert/ethereum-erc721/src/contracts/ownership/ownable.sol";
 
contract newNFT is NFTokenMetadata, Ownable {
 
  constructor() {
    nftName = "Synth NFT";
    nftSymbol = "SYN";
  }
  mapping(uint256 => uint256) public itemToToken;
  event newJewelleryAvailable(uint256 itemN, uint256 tokenN);
  event tokenTransfer(address owner, uint256 tokenID);

  function mint(address _to, uint256 _itemSN, uint256 _tokenId, string calldata _uri) external onlyOwner {
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
    itemToToken[_itemSN] = _tokenId;
    emit newJewelleryAvailable(_itemSN, _tokenId);
  }

  function approveTransfer(address buyer, uint _itemSN) external {
      super._transfer(buyer, itemToToken[_itemSN]);
      emit tokenTransfer(buyer, itemToToken[_itemSN]);
  }
 
}