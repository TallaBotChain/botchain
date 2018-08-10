pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './BotCoinPayableRegistry.sol';
import "../Upgradability/ERC721TokenKeyedScoped.sol";
import "../DeveloperRegistryInterface.sol";
import "./VoteRegistry.sol";

/**
* @title CurationCouncilRegistry
*/
contract CurationCouncilRegistry is BotCoinPayableRegistry, ERC721TokenKeyedScoped, VoteRegistry {
  using SafeMath for uint256;

  /** @dev Constructor for CurationCouncilRegistry */
  constructor(BaseStorage storage_)
    BotCoinPayableRegistry(storage_)
    ERC721TokenKeyedScoped(storage_, "curationCouncilRegistry")
    VoteRegistry(storage_)
    public
  {}

  function developerRegistry() public view returns (DeveloperRegistryInterface) {
    return DeveloperRegistryInterface(_storage.getAddress('developerRegistryAddress'));
  }

  function developerRegistryAddress() public view returns (address) {
    return _storage.getAddress('developerRegistryAddress');
  }

  function changeDeveloperRegistry(address addr) onlyOwner public {
    require(addr != 0x0);
    _storage.setAddress('developerRegistryAddress', addr);
  }

  function getVoteTotalSupply() public view returns (uint256) {
    return super.getVoteTotalSupply();
  }

  /**
  * @dev Get current stake amount for council member 
  * @param memberAddress ETH address of council member
  * @return uint256 Amount of BOTC staked by council member
  */
  function getStakeAmount(address memberAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("stakeAmount", memberAddress));
  }

  function getJoinedCouncilBlockHeight(address memberAddress) public view returns (uint256) {
    return _storage.getUint(keccak256("joinedCouncilBlockHeight", msg.sender));
  }

  /**
  * @dev Join council by staking BOTC 
  * @param stakeAmount amount of BOTC in wei
  */
  function joinCouncil(uint256 stakeAmount) public {
    require(getStakeAmount(msg.sender) == 0);
    require(botCoin().transferFrom(msg.sender, this, stakeAmount));
    uint256 memberId = totalSupply().add(1);
    _mint(msg.sender, memberId);
    _storage.setUint(keccak256("stakeAmount", msg.sender), stakeAmount);
    _storage.setUint(keccak256("joinedCouncilBlockHeight", msg.sender), block.number);
  }

  /**
  * @dev Leave council staked BOTC will be returned by contract
  */
  function leaveCouncil() public {
    require(botCoin().transfer(msg.sender, getStakeAmount(msg.sender)));
    _storage.setUint(keccak256("stakeAmount", msg.sender), 0);
  }

  /**
  * @dev Creates a new registration vote
  */
  function createRegistrationVote() public {
    require(msg.sender != 0x0);
    require(developerRegistry().owns(msg.sender) != 0);

    super.createRegistrationVote();
  }

  /**
  * @dev Casts registration vote
  * @param registrationVoteId The ID of the developer registration vote
  * @param vote true for yay false for nay
  */
  function castRegistrationVote(uint256 registrationVoteId, bool vote) public {
    require(getJoinedCouncilBlockHeight(msg.sender) < block.number);
    super.castRegistrationVote(registrationVoteId, vote);
    checkAutoApprove(registrationVoteId);
  }

  function getAutoApproveThreshold() public view returns (uint256) {
    return _storage.getUint(keccak256("autoApproveThreshold"));
  }

  function setAutoApproveThreshold(uint256 threshold) public onlyOwner {
    _storage.setUint(keccak256("autoApproveThreshold"), threshold);
  }

  function checkAutoApprove(uint256 registrationVoteId) internal {
    uint256 developerId = developerRegistry().owns(ownerOfVoteId(registrationVoteId));
    if (getYayCount(registrationVoteId) >= getAutoApproveThreshold()) {
      developerRegistry().grantApproval(developerId);
    }
  }


}
