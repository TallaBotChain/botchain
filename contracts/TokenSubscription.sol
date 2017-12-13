pragma solidity ^ 0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
 * @title TokenSubscription
 * @dev Subscription implementation for payments in token.
 */
contract TokenSubscription is Ownable {

  event SubscriptionExtended(address subscriber, uint256 payment, uint256 timeExtended);

  // Mapping of subscription end times; can be up to the maxSubscription time into the future
  mapping(address => uint256) subscriptionEndTimes;
  
  // Address where funds are collected
  address public wallet;
  
  uint256 public cost;
  uint256 public duration;
  uint256 public maxSubscription;

  // Set cost of subscription for a specified duration
  // Set the maximum amount of time that a subscriber can have subscribed into the future
  function setParameters(uint256 _cost, uint256 _duration, uint256 _maxSubscription) onlyOwner external returns(bool) {
      cost = _cost;
      duration = _duration;
      maxSubscription = _maxSubscription;
  }

  function checkStatus(address _subscriber) external returns (bool) {
    // Calculate whether subscription has expired and return boolean
  }

  // Returns the time (date?) at which the subscriber's paid subsription expires
  function checkExpiration(address _subscriber) external returns (uint256) {
    // return time at which current paid subscription expires
  }

  // Changes subscription end date
  // Forwards payment to service provider offering the subscription  
  function extend(address _subscriber, uint256 _payment) external returns (bool) {
    // Extend subscriber's subscription
    // Forward funds to service provider
  }
  
  // Forward funds to the fund collection wallet
  // Override to create custom fund forwarding mechanisms
  function forwardFunds(uint256 _payment) internal {
    wallet.transfer(_payment);
  }
}
