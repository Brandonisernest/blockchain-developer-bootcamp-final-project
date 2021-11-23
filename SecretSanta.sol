/*
General walkthrough
**Secret Santa NOT White Elephant
1. Pay to enter Main Secret Santa Smart contract
    A) for this version, make it a humble secret santa...not everybody is rich!
    B) 10 eth limit
2. The floor price needs $20 USD (0.004803 Ether as of 11/30) - implement oracle? - Chainlink for Eth price?
    A) https://data.chain.link/ethereum/mainnet/crypto-usd/eth-usd
3. Important! When you enter a santa struct, ALL you need to enter and specify are the gift name, value of the gift at time of struct creation, link to the gift (limit to amazon) 
    A) Right now, I want to not actually send the "gift" but the gift value!
    B) The information provided (i.e. gift name....it creates a gift Struct)
4. No limit to entrants to a group. 
6. Within the santa Struct, include:
    A) Gift Struct
    B) Mapping with price range to Gift Struct
    C) Mapping with address to Gift Struct
        a) Only allow one address to enter one gift struct for now
7. Gift struct:
    A) Name of Gift
    B) Value of Gift
    C) Link of Gift
8. Pseudorandomly assign gift to each person once timer expires
    A) Make sure the person can't give gift to themselves
    B) Distribute gift once timer ends
9. Allow person to choose to either receive the gift or just keep the cash value
10. You transfer ownership of giftStruct via Mapping
    A) mapping(address => giftStruct);
    
    
New Flow:
1. Enter into contract by creating gift
2. Others also enter contract by creating gift
3. The previous entrant will give gift to new entrant
4. Assign the new entrant the ownership of the gift struct
5. When the timer expires, previous entrant sends eth value to new entrant
6. the new entrant get's access (visually on webpage) to the gift and has the option to purchase with newly received eth!
    
To Dos:
1. Create events interface 
    A) When address enters the contract
2. Create contract interface
    
*/

pragma solidity 0.8.6;

contract SecretSanta {
    //owner of the contract. In case for permissioning
    address public santa;
    //when entrants are barred from entering and when gifts get distributed
    uint endTime;
    //who created the gift struct?
    mapping(address => giftStruct) public giftOriginatorMapping;
    //who owns the gift Struct
    mapping(address => giftStruct) public giftOwnershipMapping;
    //gift giving mapping
    mapping(address => address) giftDestinationMapping;
    //mapping used to order entrants
    mapping(address => uint) rankMapping;
    //arrays
    address[] public groupParticipantsArray;
    //Guard
    address public GUARD;
    //arbitrary counter for giftDestinationMapping
    uint arbitraryCounter = 0;
    
    struct giftStruct{
        string giftName;
        uint giftValue;
        string giftUrl;
    }
    
    
    //constructor where first entrant (Santa) needs to particpate too
    constructor(string memory _firstGiftName, string memory _firstGiftUrl) public payable {
        require(msg.value > 0 ether, "C'mon Santa...you gotta pay up too!");
        //arbitrary endTime
        endTime = block.timestamp * 2;
        
        //Deployer is the first entrant
        santa = msg.sender;
        //This ensures that a gift is always sent to an active address (assuming link list method)
        GUARD = santa;
        giftDestinationMapping[GUARD] = GUARD;
        groupParticipantsArray.push(santa);
        
        //santa's gift struct
        giftStruct memory firstGiftStruct = giftStruct({
            giftName : _firstGiftName,
            giftValue : msg.value,
            giftUrl : _firstGiftUrl
        });
        
        giftOriginatorMapping[santa] = firstGiftStruct;
        arbitraryCounter++;
    }
    
    modifier onlySanta() {
        require(msg.sender == santa, 'Only Santa can do this!');
        _;
    }
    
    modifier oneEntryOnly() {
        //hacky way to ensure user is not already in contract. Maybe think of something el;se
        require(giftOriginatorMapping[msg.sender].giftValue == 0, "Already in secret santa!");
        _;
    }
    
    modifier maxValue() {
        require(msg.value < 10 ether, "Value is too high! This is a reasonable secret santa");
        _;
    }
    
    modifier endTimeReached(){
        require(block.timestamp < endTime, "You missed your chance!");
        _;
    }
    
    function enterSecretSanta(string memory _giftName, string memory _giftUrl) public payable oneEntryOnly maxValue endTimeReached{
        require(msg.value > 0 ether, "You need more than zero to enter secret santa!");
      
        //front end will require just these inputs
        giftStruct memory newGiftStruct = giftStruct({
            giftName : _giftName,
            giftValue : msg.value,
            giftUrl : _giftUrl
        });
        
        //add to giftOriginatorMapping;
        giftOriginatorMapping[msg.sender] = newGiftStruct;
        //push new entrant into groupParticipantsArray
        groupParticipantsArray.push(msg.sender);
        
        //update giftDestinationMapping via linkedList approach
        
        //index for rankMapping
        address index = _findIndex(arbitraryCounter);
        //update rank table
        giftDestinationMapping[msg.sender] = giftDestinationMapping[index];
        giftDestinationMapping[index] = msg.sender;
        
        // address prevEntrant = _findPrevEntrant(msg.sender);
        address nextEntrant = _findNextEntrant(msg.sender);
        address lastEntrant = _findPrevEntrant(GUARD);
        
        //Since the linkList adds new entrants to the FRONT not the END of the linkedlist, I need to have prevEntrant point to msg.sender
        giftOwnershipMapping[lastEntrant] = giftOriginatorMapping[santa];
        //the new entrant will own the last entrants gift.
        //Since the linkList adds new entrants to the FRONT not the END of the linkedlist, I need to have prevEntrant point to msg.sender
        giftOwnershipMapping[nextEntrant] = giftOriginatorMapping[msg.sender];
        //increment counter
        arbitraryCounter++;
    }
    
   
    
    //helper functions
    function getGroupParticipants() public view returns(address[] memory){
        return groupParticipantsArray;
        
    }
    
    
    function _verifyIndex(address prevAddress, uint256 newValue, address nextAddress) 
        internal 
        view 
        returns(bool) {
            return (prevAddress == GUARD || rankMapping[prevAddress] >= newValue) && 
                   (nextAddress == GUARD || newValue > rankMapping[nextAddress]);

    }

    //returns the index of the value, which is an address
    function _findIndex(uint256 newValue) 
        internal 
        view 
        returns(address) {
            address candidateAddress = GUARD;

            while(true){
                if(_verifyIndex(candidateAddress, newValue, giftDestinationMapping[candidateAddress])){
                    return candidateAddress;
                }
                candidateAddress = giftDestinationMapping[candidateAddress];
            }

        }
        
    function _isPrevEntrant(address _address, address _prevEntrant) internal view returns(bool) {
    return giftDestinationMapping[_prevEntrant] == _address;
    }
    
    function _isNextEntrant(address _address, address _nextEntrant) internal view returns(bool) {
    return giftDestinationMapping[_address] == _nextEntrant;
    }
    
    function _findPrevEntrant(address _address) public view returns(address) {
        
        
        if (_address == GUARD){
            uint lastIndex = groupParticipantsArray.length - 1;
            return groupParticipantsArray[lastIndex];
        }
        address currentAddress = GUARD;
        while(giftDestinationMapping[currentAddress] != GUARD) {
            if(_isPrevEntrant(_address, currentAddress))
                return currentAddress;
            currentAddress = giftDestinationMapping[currentAddress];
        }
        return address(0);
    }
    
    function _findNextEntrant(address _address) public view returns(address) {
        
        address currentAddress = GUARD;
        while(giftDestinationMapping[currentAddress] != GUARD) {
            if(_isNextEntrant(_address, currentAddress))
                return currentAddress;
            currentAddress = giftDestinationMapping[currentAddress];
        }
        return address(0);
    }
    
}
