pragma solidity ^0.4.18;

contract KeyValueStorage {

  struct Multihash {
    bytes32 digest;
    uint8 fnCode;
    uint8 size;
  }

  mapping(bytes32 => uint256) _uintStorage;
  mapping(bytes32 => string) _stringStorage;
  mapping(bytes32 => address) _addressStorage;
  mapping(bytes32 => bytes) _bytesStorage;
  mapping(bytes32 => bytes32) _bytes32Storage;
  mapping(bytes32 => bool) _boolStorage;
  mapping(bytes32 => int256) _intStorage;
  mapping(bytes32 => Multihash) _multiHashStorage;
}
