pragma solidity ^ 0.4.18

/**
 * @title Subscription
 * @dev Interface for Subscription contracts
 */
contract Subscription {
  event SubscriptionFunded(address member, uint256 amount);
  event FundsCollected(address member);

  function fund(address member, uint256 amount) payable public returns (bool);
  function collectFunds(address member, uint256 amount) public returns (bool);
  function checkBalance(address member) public returns (uint256);
  function sufficientFunds(address member, greaterThanAmount uint256) public returns (uint256);
}
