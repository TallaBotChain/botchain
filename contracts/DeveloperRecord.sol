pragma solidity ^0.4.18;


contract DeveloperRecord {
  address public id;

  string public name;

  string public organization;

  string public street1;

  string public street2;

  string public city;

  string public state;

  string public postalCode;

  string public country;

  string public phone;

  string public phoneExt;

  string public email;

  address public owner;

  function DeveloperRecord() public {
    owner = msg.sender;
  }

  function updateRecord1(address i, string n, string o, string s1, string s2, string c) public {
    if (msg.sender == owner) {
      id = i;
      name = n;
      organization = o;
      street1 = s1;
      street2 = s2;
      city = c;
    }
  }

  function updateRecord2(string s, string pC, string cy, string p, string pE, string e) public {
    if (msg.sender == owner) {
      state = s;
      postalCode = pC;
      country = cy;
      phone = p;
      phoneExt = pE;
      email = e;
    }
  }
}
