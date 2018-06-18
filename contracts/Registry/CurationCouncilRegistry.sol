pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './BotCoinPayableRegistry.sol';
import "../Upgradability/ERC721TokenKeyed.sol";

/**
* @title CurationCouncilRegistry
*/
contract CurationCouncilRegistry is BotCoinPayableRegistry, ERC721TokenKeyed {
  using SafeMath for uint256;

  /**
  * @dev Event for when registration vote is created
  * @param registrationVoteId An id associated with the registration vote
  * @param initialBlock block height at which vote became valid
  * @param finalBlock block height at which vote becomes invalid
  * @param developerAddress address of developer requesting registration approval
  * @param yayCount yes vote count
  * @param nayCount no vote count
  * @param veto veto by governance board which will override all votes
  */
  event RegistrationVoteCreated(
    uint256 registrationVoteId,
    uint256 initialBlock, 
    uint256 finalBlock, 
    address developerAddress,
    uint256 yayCount,
    uint256 nayCount,
    bool veto
  );

  /** @dev Constructor for CurationCouncilRegistry */
  constructor(BaseStorage storage_)
    BotCoinPayableRegistry(storage_)
    ERC721TokenKeyed(storage_)
    public
  {}

  function getYayCount(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteYayCount", registrationVoteId));
  }

  function getNayCount(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteNayCount", registrationVoteId));
  }

  function increaseYayCount(uint256 registrationVoteId, uint256 stakeAmount) private {
    uint256 currentYayCount = getYayCount(registrationVoteId);
    _storage.setUint(keccak256("registrationVoteYayCount", registrationVoteId), currentYayCount + stakeAmount);
  }

  function increaseNayCount(uint256 registrationVoteId, uint256 stakeAmount) private {
    uint256 currentNayCount = getNayCount(registrationVoteId);
    _storage.setUint(keccak256("registrationVoteNayCount", registrationVoteId), (currentNayCount + stakeAmount));
  }

  function joinCouncil(uint256 stakeAmount) public {
    require(botCoin().transferFrom(msg.sender, this, stakeAmount));
    _storage.setUint(keccak256("stakeAmount", msg.sender), stakeAmount);
  }

  function leaveCouncil() public {
    require(botCoin().transfer(msg.sender, getStakeAmount(msg.sender)));
    _storage.setUint(keccak256("stakeAmount", msg.sender), 0);
  }

  function getStakeAmount(address memberAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("stakeAmount", memberAddress));
  }

  function getVoteInitialBlock(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteInitialBlock", registrationVoteId));
  }

  function getVoteFinalBlock(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteFinalBlock", registrationVoteId));
  }

  function getVotedOnStatus(uint256 registrationVoteId, address memberAddress) public view returns (bool) {
    return _storage.getBool(keccak256("votedOn", registrationVoteId, memberAddress));
  }

  function setVotedOnStatus(uint256 registrationVoteId) public {
    _storage.setBool(keccak256("votedOn", registrationVoteId, msg.sender), true);
  }

  function registrationVoteExists(address developerAddress) public view returns (bool) {
    return _storage.getBool(keccak256("registrationVoteExists", developerAddress));
  }

  /**
  * @dev Creates a new registration vote
  */
  function createRegistrationVote() public {
    require(msg.sender != 0x0);
    require(!registrationVoteExists(msg.sender));

    uint256 initialBlock = block.number;
    uint256 finalBlock = initialBlock + 100000;
    uint256 registrationVoteId = totalSupply().add(1);

    _mint(msg.sender, registrationVoteId);
    _storage.setBool(keccak256("registrationVoteExists", msg.sender), true);
    _storage.setAddress(keccak256("registrationVoteDeveloperAddress", registrationVoteId), msg.sender);
    _storage.setUint(keccak256("registrationVoteInitialBlock", registrationVoteId), initialBlock);
    _storage.setUint(keccak256("registrationVoteFinalBlock", registrationVoteId), finalBlock);
    _storage.setUint(keccak256("registrationVoteYayCount", registrationVoteId), 0);
    _storage.setUint(keccak256("registrationVoteNayCount", registrationVoteId), 0);

    emit RegistrationVoteCreated(registrationVoteId, initialBlock, finalBlock, msg.sender, 0, 0, false);
  }

  /**
  * @dev Casts registration vote
  */
  function castRegistrationVote(uint256 registrationVoteId, bool vote) public {
    require(!getVotedOnStatus(registrationVoteId, msg.sender));
    
    if (vote) {
      increaseYayCount(registrationVoteId, getStakeAmount(msg.sender));
    } else {
      increaseNayCount(registrationVoteId, getStakeAmount(msg.sender));
    }

    setVotedOnStatus(registrationVoteId);
  }


}
