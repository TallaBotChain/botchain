pragma solidity ^0.4.18;

import "../Registry/CurationCouncilRegistry.sol";

/**
 * @title CurationCouncilRegistryDelegate
 * @dev Delegate contract for functionality that handles curation of developers on the platform.
 */
contract CurationCouncilRegistryDelegate is CurationCouncilRegistry {

  string public constant name = "CurationCouncilRegistry";

  /**
  * @dev Constructor for CurationCouncilRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  function CurationCouncilRegistryDelegate(BaseStorage storage_)
    CurationCouncilRegistry(storage_)
    public
  {}

  function joinCouncil(uint256 stakeAmount)
    public
  {
    super.joinCouncil(stakeAmount);
  }

  function leaveCouncil()
    public
  {
    super.leaveCouncil();
  }

  function createRegistrationVote(address developerAddress) public {
    super.createRegistrationVote(developerAddress);
  }

  function castRegistrationVote(
    uint256 registrationVoteId,
    bool vote
  )
    public
  {
    super.castRegistrationVote(registrationVoteId, vote);
  }

  function getVoteInitialBlock(uint256 registrationVoteId) public view returns (uint256) {
    return super.getVoteInitialBlock(registrationVoteId);
  }

  function getVoteFinalBlock(uint256 registrationVoteId) public view returns (uint256) {
    return super.getVoteFinalBlock(registrationVoteId);
  }

}
