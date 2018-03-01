"DeveloperRegistry" is the main contract

"developerRecord" is a contract that contains all the information of a developer record. A new one gets created whenever an address wants a new developer record.

"bot" is a contract that contains all the information for bots. A new one gets created whenever an address wants a new bot.

"Owners" are addresses who can make changes to the contract. Right now they can add or remove an owner and add or remove an approved developer.

"Approved Developers" are addresses that are allowed to have a developer record.

————————————————————————
DeveloperRegistry Data Functions:
————————————————————————

isOwner(address) - returns true if address is an owner

isApprovedDev(address) - returns true if address is an approved dev

botDeveloperRecords(address) - returns the address of the developer record for the address, 0x0 if none exists.

botOwners(address) - returns the address of the developer record associated with the bot of the address passed in.

————————————————
DeveloperRegistry Arrays:
————————————————

owners - list of all owners

approvedDevs - list of all approved developers

bots - list of all bots

———————————————————
DeveloperRegistry Functions:
———————————————————

DeveloperRegistry() - Makes the contract, sets address creating contract as an owner

addOwner(address newOwner) - adds the address passed in to the owner list

removeOwner(address ownerToRemove) - removes the address passed from the owner list

addApprovedDev(address newDev) - adds the address passed to the approved developers list.

removeApprovedDev(address dev) - removes the address passed from the approved dev list.

addDeveloperRecord() - creates a new developer record for address that sent the request.

updateDeveloperRecord(string name, string organization, string street1, string street2, string city, string state, string postalCode, string country, string phone, string phoneExt, string email) - updates developer record for address that is making the request.

addBot(string name, string description, string tags) - creates a bot for address that sent the request.

updateBot(address id, string name, string description, string tags) - updates bot with id.

———————————————————————————————
developerRecord Data Functions:
———————————————————————————————

id() - the address that created this developerRecord

name()

organization()

street1()

street2()

city()

state()

postalCode()

country()

phone()

phoneExt()

email()

———————————————————
bot Data Functions:
———————————————————

org() - address of developerRecord associated with bot

name()

description()

tags()
