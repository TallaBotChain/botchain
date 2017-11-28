pragma solidity ^0.4.18;


contract Bot {

  address public org;

  string public name;

  string public description;

  string public tags;

  address public owner;

  function Bot(address o, string n, string d, string t) public {
    org = o;
    name = n;
    description = d;
    tags = t;

    owner = msg.sender;
  }

  function updateBot(address o, string n, string d, string t) public {
    if (owner == msg.sender) {
      org = o;
      name = n;
      description = d;
      tags = t;
    }
  }
}