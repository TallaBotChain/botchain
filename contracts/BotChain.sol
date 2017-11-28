pragma solidity ^0.4.18;

contract BotChain {
    
    //Returns true if address is an owner of this contract
    mapping(address => bool) public isOwner;
    //Returns the index of address in owners array
    mapping(address => uint256) public ownerIndex;
    //Array of all owners addresses
    address[] public owners;
    
    //Returns true if address belongs to an approved developer
    mapping(address => bool) public isApprovedDev;
    //Returns the index of address in the approvedDevs array
    mapping(address => uint256) public devIndex;
    //List of all approved developer addresses
    address[] public approvedDevs;
    
    //Returns address of DeveloperRecord associated with given address
    mapping(address => address) public botDeveloperRecords;
    
    //Returns the address of the owner of the given bot
    mapping(address => address) public botOwners;
    //Returns index of address in bots array
    mapping(address => uint256) public botIndex;
    //List of all bot addresses
    address[] public bots;
    
    //Creates a BotChain Contract with sender as an owner
    function BotChain () public {
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
    }
    
    //Adds a new owner to the BotChain contract
    function addOwner(address newOwner) public {
        if(isOwner[msg.sender] && !isOwner[newOwner]) {
            isOwner[newOwner] = true;
            if(owners.length > ownerIndex[msg.sender] && owners[ownerIndex[msg.sender]]==0x0) {
                owners[ownerIndex[msg.sender]] = msg.sender;
            } else {
                ownerIndex[msg.sender] = owners.length;
                owners.push(newOwner);
            }
        } else {
            revert();
        }
    }
    
    //Removes an owner from the BotChain contract
    function removeOwner(address ownerToRemove) public {
        if(isOwner[msg.sender] && isOwner[ownerToRemove]) {
            isOwner[ownerToRemove] = false;
            owners[ownerIndex[msg.sender]]=0x0;
        } else {
            revert();
        }
    }
    
    //Adds an address to the list of approved developers
    function addApprovedDev(address newDev) public {
        if(isOwner[msg.sender] && !isApprovedDev[newDev]) {
            isApprovedDev[newDev] = true;
            if(approvedDevs.length > devIndex[msg.sender] && approvedDevs[devIndex[msg.sender]]==0x0) {
                approvedDevs[devIndex[msg.sender]] = msg.sender;
            } else {
                devIndex[msg.sender] = approvedDevs.length;
                approvedDevs.push(newDev);
            }
        } else {
            revert();
        }
    }
    
    //Removes an address from the list of approved developers
    function removeApprovedDev(address dev) public {
        if(isOwner[msg.sender] && isApprovedDev[dev]) {
            isApprovedDev[dev] = false;
            approvedDevs[devIndex[msg.sender]]=0x0;
        } else {
            revert();
        }
    }
    
    //Creates a new DeveloperRecord if the sender is an approved dev and has not already created a DeveloperRecord.
    //Note: new DeveloperRecord will be empty, updateDeveloperRecord will need to be called.
    function addDeveloperRecord() public {
        if(isApprovedDev[msg.sender] && botDeveloperRecords[msg.sender]==0x0) {
            DeveloperRecord devRecord = new DeveloperRecord();
            botDeveloperRecords[msg.sender] = devRecord;
        } else {
            revert();
        }
    }
    
    //Updates DeveloperRecord associated with sender address if sender is an approved developer
    function updateDeveloperRecord(string name, string organization, string street1, string street2, string city, string state, string postalCode, string country, string phone, string phoneExtension, string email) public {
        if(isApprovedDev[msg.sender] && botDeveloperRecords[msg.sender]!=0x0) {
            DeveloperRecord devRecord = DeveloperRecord(botDeveloperRecords[msg.sender]);
            devRecord.updateRecord1(msg.sender,name,organization,street1,street2,city);
            devRecord.updateRecord2(state,postalCode,country,phone,phoneExtension,email);
        }
    }
    
    //Creates a new bot belonging to sender address if sender is an approved developer
    function addBot(string name, string date, string tags) public {
        if(isApprovedDev[msg.sender] && botDeveloperRecords[msg.sender] != 0x0) {
            Bot newBot = new Bot(botDeveloperRecords[msg.sender], name, date, tags);
            botOwners[newBot] = botDeveloperRecords[msg.sender];
            botIndex[newBot] = bots.length;
            bots.push(newBot);
        } else {
            revert();
        }
    }
    
    //Edits a bot with id belonging to sender address if sender is an approved developer
    function updateBot(address id, string name, string date, string tags) public {
        if(isApprovedDev[msg.sender] && botOwners[id]==msg.sender) {
            Bot thisBot = Bot(id);
            thisBot.updateBot(botDeveloperRecords[msg.sender], name, date, tags);
        } else {
            revert();
        }
    }
    
}

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
        if(msg.sender==owner) {
            id = i;
            name = n;
            organization = o;
            street1 = s1;
            street2 = s2;
            city = c;
        }
    }
    
    function updateRecord2(string s, string pC, string cy, string p, string pE, string e) public {
        if(msg.sender==owner) {
            state = s;
            postalCode = pC;
            country = cy;
            phone = p;
            phoneExt = pE;
            email = e;
        }
    }
}

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
        if(owner==msg.sender) {
            org = o;
            name = n;
            description = d;
            tags = t;
        }
    }
}