pragma solidity ^ 0.4.18

/**
 * @title Subscription
 * @dev Interface for Subscription contracts
 */
contract Subscription {
  event SubscriptionExtended(address subscriber, uint256 payment, uint256 timeExtended);

  function setSubscriptionParameters(uint256 cost, uint256 duration, uint256 maxSubscription) public returns(bool);
  function extendSubscription(address subscriber, uint256 payment) payable public returns (bool);
  function checkSubscriptionStatus(address subscriber) public returns (bool);
  function checkSubscriptionExpiration(address subscriber) public returns (uint256);
}
