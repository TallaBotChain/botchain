pragma solidity ^0.4.18;

import "../Registry/CurationCouncilRegistry.sol";
import "../Registry/OwnerRegistry.sol";

/**
 * @title CurationCouncilRegistryDelegate
 * @dev Delegate contract for functionality that handles curation of developers on the platform.
 */
contract CurationCouncilRegistryDelegate is CurationCouncilRegistry, OwnerRegistry {

  string public constant name = "CurationCouncilRegistry";

  /**
  * @dev Constructor for CurationCouncilRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  function CurationCouncilRegistryDelegate(BaseStorage storage_)
    CurationCouncilRegistry(storage_)
    public
  {}

  function joinCouncil(
    address memberAddress,
    uint256 stakeAmount
  )
    public
  {
    joinCouncil(memberAddress, stakeAmount);
  }

  function leaveCouncil(
    address memberAddress,
    uint256 stakeAmount
  )
    public
  {
    leaveCouncil(memberAddress);
  }

  function createRegistrationVote(address developerAddress) public {
    createRegistrationVote(developerAddress);
  }

  function castRegistrationVote(
    uint256 registrationVoteId,
    bool vote
  )
    public
  {
    castRegistrationVote(registrationVoteId, vote);
  }

  function getVoteInitialBlock(uint256 registrationVoteId) public view returns (uint256) {
    return getVoteInitialBlock(registrationVoteId);
  }

  function getVoteFinalBlock(uint256 registrationVoteId) public view returns (uint256) {
    return getVoteFinalBlock(registrationVoteId);
  }

}
