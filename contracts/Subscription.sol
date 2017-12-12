pragma solidity ^ 0.4.18;

/**
 * @title Subscription
 * @dev Interface for Subscription contracts
 */
contract Subscription {
  function setParameters(uint256 cost, uint256 duration, uint256 maxSubscription) external returns(bool);
  function checkStatus(address subscriber) external returns (bool);
  function checkExpiration(address subscriber) external returns (uint256);
}
