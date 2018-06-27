pragma solidity ^0.4.18;

import "../Registry/CurationCouncilRegistry.sol";

/**
 * @title CurationCouncilRegistryDelegate
 * @dev Delegate contract for functionality that handles curation of developers on the platform.
 */
contract CurationCouncilRegistryDelegate is CurationCouncilRegistry {

  string public constant name = "CurationCouncilRegistry";
  address tokenVaultAddress;

  /**
  * @dev Constructor for CurationCouncilRegistryDelegate
  * @param storage_ address of a BaseStorage contract
  */
  constructor(BaseStorage storage_, address tokenVaultAddress_)
    CurationCouncilRegistry(storage_)
    public
  {
    tokenVaultAddress = tokenVaultAddress_;
  }

  function applyCuratorReward_Signature() private returns (bool) {
    require(tokenVaultAddress.call(bytes4(keccak256("applyCuratorReward()"))));
    return true;
  }

  /**
  * @dev Join council by staking BOTC 
  * @param stakeAmount amount of BOTC in wei
  */
  function joinCouncil(uint256 stakeAmount)
    public
  {
    super.joinCouncil(stakeAmount);
  }

  /**
  * @dev Leave council staked BOTC will be returned by contract
  */
  function leaveCouncil()
    public
  {
    super.leaveCouncil();
  }

  /**
  * @dev Creates a new registration vote
  */
  function createRegistrationVote() public {
    super.createRegistrationVote();
  }

  /**
  * @dev Casts registration vote
  * @param registrationVoteId The ID of the developer registration vote
  * @param vote true for yay false for nay
  */
  function castRegistrationVote(
    uint256 registrationVoteId,
    bool vote
  )
    public
  {
    super.castRegistrationVote(registrationVoteId, vote);
    applyCuratorReward_Signature();
  }

  /**
  * @dev Get initial block height where the vote starts
  * @param registrationVoteId The ID of the developer registration vote
  * @return uint256 ETH block height where the vote starts
  */
  function getVoteInitialBlock(uint256 registrationVoteId) public view returns (uint256) {
    return super.getVoteInitialBlock(registrationVoteId);
  }

  /**
  * @dev Get final block height where the vote ends
  * @param registrationVoteId The ID of the developer registration vote
  * @return uint256 ETH block height where the vote ends
  */
  function getVoteFinalBlock(uint256 registrationVoteId) public view returns (uint256) {
    return super.getVoteFinalBlock(registrationVoteId);
  }

}
