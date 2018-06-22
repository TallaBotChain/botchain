# BotChain Test Mock Objects

The contracts in this directory are strictly for testing purposes.
They allow for simplifying depedencies in the unit testing environment.
Placing a mock in this directory rather than <botchain root>/test/mocks
allows for it to be used through truffle directly.


```
$ npm test
```

Run `npm run test:coverage` to run with coverage reporting

For an overview of how the contracts involved in the process and how they operate
please refer to the [Botchain Overview](https://github.com/TallaBotChain/botchain#botchain-overview).
