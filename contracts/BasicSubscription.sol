pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Subscription.sol';

/**
 * @title BasicSubscription
 * @dev Basic implementation of a Subscription
 */
contract BasicSubscription is Subscription, Ownable {

  // Mapping of subscription end times; can be up to the maxSubscription time into the future
  mapping(address => uint256) subscriptionEndTimes;
  
  // Address where funds are collected
  address public wallet;
  
  uint256 cost;
  uint256 duration;
  uint256 maxSubscription;

  // Set cost of subscription for a specified duration
  // Set the maximum amount of time that a subscriber can have subscribed into the future
  function setParameters(uint256 _cost, uint256 _duration, uint256 _maxSubscription) onlyOwner external returns(bool) {
    //  Set contract values to passed in parameters
  }

  function checkStatus(address _subscriber) external returns (bool) {
    // Calculate whether subscription has expired and return boolean
  }

  // Returns the time (date?) at which the subscriber's paid subsription expires
  function checkExpiration(address _subscriber) external returns (uint256) {
    // return time at which current paid subscription expires
  }
}
