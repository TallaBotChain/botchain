pragma solidity ^ 0.4.18;

import './BasicSubscription.sol';

/**
 * @title TokenSubscription
 * @dev Subscription implementation for payments in token.
 */
contract TokenSubscription is BasicSubscription {

  event SubscriptionExtended(address subscriber, uint256 payment, uint256 timeExtended);

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
