pragma solidity ^0.4.18;


import './DeveloperRecord.sol';
import './Bot.sol';


contract BotChain {
    
    //Returns true if address is an owner of this contract
    mapping(address => bool) public isOwner;
    
    //Returns true if address belongs to an approved developer
    mapping(address => bool) public isApprovedDev;
    
    //Returns the address of the owner of the given bot
    mapping(address => address) public botOwners;

    //List of all bot addresses
    address[] public bots;
    
    //Creates a BotChain Contract with sender as an owner
    function BotChain() public {
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
    }
    
    //Adds a new owner to the BotChain contract
    function addOwner(address newOwner) public {
        if(isOwner[msg.sender] && !isOwner[newOwner]) {
            // add newOwner as owner
        } else {
            revert();
        }
    }
    
    //Removes an owner from the BotChain contract
    function removeOwner(address ownerToRemove) public {
        if(isOwner[msg.sender] && isOwner[ownerToRemove]) {
            //  Remove ownerToRemove from owners
        } else {
            revert();
        }
    }
    
    //Adds an address to the list of approved developers
    function addApprovedDev(address newDev) public {
        if(isOwner[msg.sender] && !isApprovedDev[newDev]) {
            // Set neDev as approved
        } else {
            revert();
        }
    }
    
    //Removes an address from the list of approved developers
    function removeApprovedDev(address dev) public {
        if(isOwner[msg.sender] && isApprovedDev[dev]) {
            // Set dev as not approved
        } else {
            revert();
        }
    }
    
    //Creates a new bot belonging to sender address if sender is an approved developer
    function addBot(address botAddress, string metaData) public {
        // Check that msg.sender is an approvedDev with necessary information (i.e. metaData)
        if() {
            // Set botOwner
            // Create bot record
        } else {
            revert();
        }
    }
    
    //Edits a bot's metaData hash
    function updateBot(address id, string metaData) public {
        if(isApprovedDev[msg.sender] && botOwners[id]==msg.sender) {
            // Update bot metadata
        } else {
            revert();
        }
    }
    
    //Verify that a bot is registered
    function verifyBot(address id, string metaData) public {
        // check that bot is present with passed in metaData hash
    }
}
