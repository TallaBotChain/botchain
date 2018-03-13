pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "../Upgradability/StorageConsumer.sol";
import "./OwnerRegistry.sol";
import "./Registry.sol";

/**
 * @title OwnableRegistry
 * @dev Registry of token ID's that are owned by another token from a different registry
 */
contract OwnableRegistry is Registry, StorageConsumer {
  using SafeMath for uint256;

  /* @dev Constructor for OwnableRegistry */
  function OwnableRegistry(BaseStorage storage_) StorageConsumer(storage_) public {}

  /**
  * @dev Gets address for owner registry
  */
  function ownerRegistry() public view returns (OwnerRegistry) {
    return OwnerRegistry(_storage.getAddress("ownerRegistryAddress"));
  }

  /**
  * @dev Gets the total amount of tokens stored by the contract
  * @return uint256 representing the total amount of tokens
  */
  function totalSupply() public view returns (uint256) {
    return _storage.getUint("totalTokens");
  }

  /**
  * @dev Gets the balance of the specified token
  * @param _ownerTokenId token ID to query the balance of
  * @return uint256 representing the amount owned by the passed token ID
  */
  function balanceOf(uint256 _ownerTokenId) public view returns (uint256) {
    return _storage.getUint(keccak256("ownerBalances", _ownerTokenId));
  }

  /**
  * @dev Gets the list of tokens owned by a given token ID
  * @param _ownerTokenId uint256 to query the tokens of
  * @return uint256[] representing the list of tokens owned by the passed token ID
  */
  function tokensOf(uint256 _ownerTokenId) public view returns (uint256[]) {
    uint256 _ownerBalance = balanceOf(_ownerTokenId);
    uint256[] memory _tokens = new uint256[](_ownerBalance);
    for (uint256 i = 0; i < _ownerBalance; i++) {
      _tokens[i] = getOwnedToken(_ownerTokenId, i);
    }
    return _tokens;
  }

  /**
  * @dev Gets the owner id of the specified token ID
  * @param _tokenId uint256 ID of the token to query the owner id of
  * @return ownerTokenId token ID currently marked as the owner id of the given token ID
  */
  function ownerOf(uint256 _tokenId) public view returns (uint256) {
    uint256 ownerTokenId = getTokenOwner(_tokenId);
    require(ownerTokenId != 0);
    return ownerTokenId;
  }

  /**
  * @dev Returns id of owner of entry
  * @param _entryId The id of the entry
  * @return id that owns the entry with the given id
  */
  function ownerOfEntry(uint256 _entryId) public view returns (address) {
    uint256 parentEntryId = ownerOf(_entryId);
    return ownerRegistry().ownerOfEntry(parentEntryId);
  }

  /**
  * @dev Mint token function
  * @param _ownerTokenId uint256 ID of the token that will own the minted token
  * @param _tokenId uint256 ID of the token to be minted by the msg.sender
  */
  function _mint(uint256 _ownerTokenId, uint256 _tokenId) internal {
    require(_ownerTokenId != 0);
    addToken(_ownerTokenId, _tokenId);
  }

  /**
  * @dev Internal function to get token owner by token ID
  * @param tokenId uint256 ID of the token to get the owner for
  * @return uint255 The ID of the token that owns the token an with ID of tokenId
  */
  function getTokenOwner(uint256 tokenId) private view returns (uint256) {
    return _storage.getUint(keccak256("tokenOwners", tokenId));
  }

  /**
  * @dev Internal function to get an ID value from list of owned token ID's
  * @param ownerTokenId The token ID for the owner of the token list
  * @param tokenIndex uint256 The index of the token ID value within the list
  * @return uint256 The token ID for the given owner and token index
  */
  function getOwnedToken(uint256 ownerTokenId, uint256 tokenIndex) private view returns (uint256) {
    return _storage.getUint(keccak256("ownedTokens", ownerTokenId, tokenIndex));
  }

  /**
  * @dev Internal function to get the index of a token ID within the owned tokens list
  * @param tokenId uint256 ID of the token to get the index for
  * @return uint256 The index of the token for the given ID
  */
  function getOwnedTokenIndex(uint256 tokenId) private view returns (uint256) {
    return _storage.getUint(keccak256("ownedTokensIndex", tokenId));
  }

  /**
  * @dev Internal function to add a token ID to the list of a given owner token ID
  * @param _toOwnerTokenId uint256 representing the new owner of the given token ID
  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given owner token ID
  */
  function addToken(uint256 _toOwnerTokenId, uint256 _tokenId) private {
    require(getTokenOwner(_tokenId) == 0);
    setTokenOwner(_tokenId, _toOwnerTokenId);
    uint256 length = balanceOf(_toOwnerTokenId);
    pushOwnedToken(_toOwnerTokenId, _tokenId);
    setOwnedTokenIndex(_tokenId, length);
    incrementTotalTokens();
  }
  
  /**
  * @dev Internal function to increase totalTokens by 1
  */
  function incrementTotalTokens() private {
    _storage.setUint("totalTokens", totalSupply().add(1));
  }

  /**
  * @dev Internal function to decrease totalTokens by 1
  */
  function decrementTotalTokens() private {
    _storage.setUint("totalTokens", totalSupply().sub(1));
  }

  /**
  * @dev Internal function to set token owner by token ID
  * @param tokenId uint256 ID of the token to set the owner for
  * @param ownerTokenId uint256 The ID of the token owner
  */
  function setTokenOwner(uint256 tokenId, uint256 ownerTokenId) private {
    _storage.setUint(keccak256("tokenOwners", tokenId), ownerTokenId);
  }

  /**
  * @dev Internal function to increment an owner's token balance by 1
  * @param ownerTokenId uint256 The owner's token ID
  */
  function incrementOwnerBalance(uint256 ownerTokenId) private {
    _storage.setUint(keccak256("ownerBalances", ownerTokenId), balanceOf(ownerTokenId).add(1));
  }

  /**
  * @dev Internal function to decrement an owner's token balance by 1
  * @param ownerTokenId uint256 The owner's token ID
  */
  function decrementOwnerBalance(uint256 ownerTokenId) private {
    _storage.setUint(keccak256("ownerBalances", ownerTokenId), balanceOf(ownerTokenId).sub(1));
  }

  /**
  * @dev Internal function to set an ID value within a list of owned token ID's
  * @param ownerTokenId uint256 The token ID of the owner of the token list
  * @param tokenIndex uint256 The index to set within the owned token list
  * @param tokenId uint256 The ID of the token to set
  */
  function setOwnedToken(uint256 ownerTokenId, uint256 tokenIndex, uint256 tokenId) private {
    _storage.setUint(keccak256("ownedTokens", ownerTokenId, tokenIndex), tokenId);
  }

  /**
  * @dev Internal function to append an ID value to a list of owned token ID's
  * @param ownerTokenId uint256 The token ID of the owner of the token list
  * @param tokenId uint256 The token ID to append
  */
  function pushOwnedToken(uint256 ownerTokenId, uint256 tokenId) private {
    _storage.setUint(keccak256("ownedTokens", ownerTokenId, balanceOf(ownerTokenId)), tokenId);
    incrementOwnerBalance(ownerTokenId);
  }

  /**
  * @dev Internal function to set the index of a token ID within the owned tokens list
  * @param tokenId uint256 ID of the token to set the index for
  * @param tokenIndex uint256 The token index to set for the given token ID
  */
  function setOwnedTokenIndex(uint256 tokenId, uint256 tokenIndex) private {
    _storage.setUint(keccak256("ownedTokensIndex", tokenId), tokenIndex);
  }
}
