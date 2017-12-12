pragma solidity ^ 0.4.18

/**
 * @title EtherSubscription
 * @dev Subscription implementation for ether payments.
 */
contract EtherSubscription is BasicSubscription {

  event SubscriptionExtended(address subscriber, uint256 payment, uint256 timeExtended);

  // Changes subscription end date
  // Forwards payment to service provider offering the subscription  
  function extend(address _subscriber) payable external returns (bool) {
    // Extend subscriber's subscription
    // Forward funds to service provider
  }

  // Forward funds to the fund collection wallet
  // Override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
