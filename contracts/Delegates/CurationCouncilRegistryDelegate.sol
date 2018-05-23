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
    super.joinCouncil(memberAddress, stakeAmount)
  }

  function leaveCouncil(
    address memberAddress,
    uint256 stakeAmount
  )
    public
  {
    super.leaveCouncil(memberAddress, stakeAmount)
  }

  function createRegistrationVote(address developerAddress) public {
    super.createRegistrationVote(developerAddress)
  }

  function castRegistrationVote(
    uint256 registrationVoteId,
    bool vote
  )
    public
  {
    super.castRegistrationVote(registrationVoteId, vote)
  }

  function getPendingRegistrationVotes public returns {
    return super.getPendingRegistrationVotes
  }

}
