# Notes on writing an running tests

* The easiest way is to run `truffle develop` then type `test` (See [notes on truffle develop](https://github.com/trufflesuite/truffle/releases/tag/v4.0.0)) 

* When [calling a solidity function in a test](http://truffleframework.com/docs/getting_started/contracts#making-a-call)
  * Use call to indicate a non-persisting contract method call
  * Use direct method to indicate a transactional call that makes changes

