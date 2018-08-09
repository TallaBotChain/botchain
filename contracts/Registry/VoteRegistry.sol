pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import "../Upgradability/ERC721TokenKeyedScoped.sol";

/**
* @title VoteRegistry
*/
contract VoteRegistry is ERC721TokenKeyedScoped {
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
    ERC721TokenKeyedScoped(storage_, "voteRegistry")
    public
  {}

  function getVoteTotalSupply() public view returns (uint256) {
    return totalSupply();
  }

  function ownerOfVoteId(uint256 registrationVoteId) public view returns (address) {
    return ownerOf(registrationVoteId);
  }

  /**
  * @dev Gets the Yay count for a specific developer registration vote
  * @param registrationVoteId The ID of the developer registration vote
  * @return uint256 Count of Yay votes
  */
  function getYayCount(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteYayCount", registrationVoteId));
  }

  /**
  * @dev Gets the Nay count for a specific developer registration vote
  * @param registrationVoteId The ID of the developer registration vote
  * @return uint256 Count of Nay votes
  */
  function getNayCount(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteNayCount", registrationVoteId));
  }

  /**
  * @dev Increase Yay count for a particular vote by the stake amount
  * @param registrationVoteId The ID of the developer registration vote
  * @param stakeAmount the stake amount of the council member that will be applied to this vote
  */
  function increaseYayCount(uint256 registrationVoteId, uint256 stakeAmount) private {
    uint256 currentYayCount = getYayCount(registrationVoteId);
    _storage.setUint(keccak256("registrationVoteYayCount", registrationVoteId), currentYayCount + stakeAmount);
  }

  /**
  * @dev Increase Nay count for a particular vote by the stake amount
  * @param registrationVoteId The ID of the developer registration vote
  * @param stakeAmount The stake amount of the council member that will be applied to this vote
  */
  function increaseNayCount(uint256 registrationVoteId, uint256 stakeAmount) private {
    uint256 currentNayCount = getNayCount(registrationVoteId);
    _storage.setUint(keccak256("registrationVoteNayCount", registrationVoteId), (currentNayCount + stakeAmount));
  }

  /**
  * @dev Get current stake amount for council member 
  * @param memberAddress ETH address of council member
  * @return uint256 Amount of BOTC staked by council member
  */
  function getStakeAmount(address memberAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("stakeAmount", memberAddress));
  }

  /**
  * @dev Get initial block height where the vote starts
  * @param registrationVoteId The ID of the developer registration vote
  * @return uint256 ETH block height where the vote starts
  */
  function getVoteInitialBlock(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteInitialBlock", registrationVoteId));
  }

  /**
  * @dev Get final block height where the vote ends
  * @param registrationVoteId The ID of the developer registration vote
  * @return uint256 ETH block height where the vote ends
  */
  function getVoteFinalBlock(uint256 registrationVoteId) public view returns (uint256) {
    return _storage.getUint(keccak256("registrationVoteFinalBlock", registrationVoteId));
  }

  /**
  * @dev Check to see if council member has already voted
  * @param registrationVoteId The ID of the developer registration vote
  * @param memberAddress ETH address of the council member
  * @return bool true if voted already submitted, otherwise false
  */
  function getVotedOnStatus(uint256 registrationVoteId, address memberAddress) public view returns (bool) {
    return _storage.getBool(keccak256("votedOn", registrationVoteId, memberAddress));
  }

  /**
  * @dev Sets voted on status for council member
  * @param registrationVoteId The ID of the developer registration vote
  */
  function setVotedOnStatus(uint256 registrationVoteId) public {
    _storage.setBool(keccak256("votedOn", registrationVoteId, msg.sender), true);
  }

  /**
  * @dev Check to see if developer already has a vote
  * @param developerAddress ETH address of the developer
  * @return bool true if developer already exists, otherwise false
  */
  function registrationVoteExists(address developerAddress) public view returns (bool) {
    return _storage.getBool(keccak256("registrationVoteExists", developerAddress));
  }

  /**
  * @dev Creates a new registration vote
  */
  function createRegistrationVote() public {
    require(!registrationVoteExists(msg.sender));

    uint256 initialBlock = block.number;
    uint256 finalBlock = initialBlock + 100000;
    uint256 registrationVoteId = totalSupply().add(1);

    _mint(msg.sender, registrationVoteId);
    _storage.setBool(keccak256("registrationVoteExists", msg.sender), true);
    _storage.setUint(keccak256("registrationVoteInitialBlock", registrationVoteId), initialBlock);
    _storage.setUint(keccak256("registrationVoteFinalBlock", registrationVoteId), finalBlock);
    _storage.setUint(keccak256("registrationVoteYayCount", registrationVoteId), 0);
    _storage.setUint(keccak256("registrationVoteNayCount", registrationVoteId), 0);

    emit RegistrationVoteCreated(registrationVoteId, initialBlock, finalBlock, msg.sender, 0, 0, false);
  }

  /**
  * @dev Casts registration vote
  * @param registrationVoteId The ID of the developer registration vote
  * @param vote true for yay false for nay
  */
  function castRegistrationVote(uint256 registrationVoteId, bool vote) public {
    require(!getVotedOnStatus(registrationVoteId, msg.sender));
    require(getVoteFinalBlock(registrationVoteId) >= block.number);

    if (vote) {
      increaseYayCount(registrationVoteId, getStakeAmount(msg.sender));
    } else {
      increaseNayCount(registrationVoteId, getStakeAmount(msg.sender));
    }

    setVotedOnStatus(registrationVoteId);
  }


}
