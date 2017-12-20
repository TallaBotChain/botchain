pragma solidity ^ 0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/token/ERC20.sol';

/**
 * @title TokenSubscription
 * @dev Subscription implementation for payments in token.
 */
contract TokenSubscription is Ownable {

  event SubscriptionExtended(address subscriber, uint256 payment, uint256 timeExtended);

  // Mapping of subscription end times; can be up to the maxSubscription time into the future
  mapping(address => uint256) public subscriptionEndTimes;
  
  // Address where funds are collected
  address public wallet;
  
  uint256 public cost; // in botcoin
  uint256 public duration; // in weeks
  uint256 public maxSubscriptionLength; // in weeks
  
  ERC20 public token;

  // Add constructor to set default cost, duration, maxSubscriptionLength, ERC20 token, and wallet
  function TokenSubscription(ERC20 _token, address _wallet, uint256 _cost, uint256 _duration, uint256 _maxSubscriptionLength) public {
    wallet = _wallet;
    token = _token;
    cost = _cost;
    duration = _duration;
    maxSubscriptionLength = _maxSubscriptionLength;
  }

  // Update cost of subscription for a specified duration
  // Update the maximum amount of time that a subscriber can have subscribed into the future
  function updateParameters(uint256 _cost, uint256 _duration, uint256 _maxSubscriptionLength) onlyOwner external returns(bool) {
      cost = _cost;
      duration = _duration;
      maxSubscriptionLength = _maxSubscriptionLength;
  }

  // Check whether developer has been registered/subscribed before
  function checkRegistration(address _subscriber) public returns (bool) {
    // check to see if subscriber is in the system
    return subscriptionEndTimes[_subscriber] != 0;
  }

  // Calculate whether registered subscriber is currently paid
  function checkStatus(address _subscriber) external returns (bool) {
    require(checkRegistration(_subscriber));
    return subscriptionEndTimes[_subscriber] > now;
  }

  // Returns the time at which the registered subscriber's subsription expires
  function checkExpiration(address _subscriber) public returns (uint256) {
    require(checkRegistration(_subscriber));
    // return time at which current paid subscription expires
    return subscriptionEndTimes[_subscriber];
  }

  // Changes subscription end date
  // Forwards payment to service provider offering the subscription  
  function extend(uint256 _payment) external returns (bool) {
    // Calculate amount to extend subscription
    // TODO Can extend any amount of time or only in discreet units?
    uint256 timeToExtend = ((_payment/cost) * duration) * 1 weeks;
    // Check if currently subscribed
    if (checkRegistration(msg.sender)) {
      // Check that maxSubscriptionLength not exceeded
      // Note that current time can only be relied on as an approximation
      require(((checkExpiration(msg.sender) - now) + timeToExtend) < maxSubscriptionLength * 1 weeks);
      // Extend subscriber's subscription
      subscriptionEndTimes[msg.sender] = subscriptionEndTimes[msg.sender] + timeToExtend;
    } else {
      // Check that maxSubscriptionLength not exceeded
      // Note that current time can only be relied on as an approximation
      require(timeToExtend < maxSubscriptionLength * 1 weeks);
      // Set subscription expiration
      subscriptionEndTimes[msg.sender] = now + timeToExtend;
    }
    
    // Forward funds to service provider
    forwardFunds(msg.sender, _payment);
    // TODO return boolean?
  }
  
  // Forward funds to the fund collection wallet
  // Override to create custom fund forwarding mechanisms
  function forwardFunds(address _subscriber, uint256 _payment) internal {
    // Note for testing approve transaction first
    token.transferFrom(_subscriber, wallet, _payment);
  }
}
