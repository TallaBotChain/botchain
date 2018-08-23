pragma solidity ^0.4.18;

import "./BaseStorage.sol";

contract PublicStorage is BaseStorage {

  function senderIsValid() private view returns (bool) {
    return msg.sender != 0x0;
  }

  function scopedKey(bytes12 key) internal view returns(bytes32) {
    bytes32 scoped_key = 0;
    scoped_key |= bytes32(msg.sender) << (12*8);
    return  scoped_key |= key;
  }

}
