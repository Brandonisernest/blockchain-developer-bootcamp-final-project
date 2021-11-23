/*
New Flow:
1. Enter into contract by creating gift (done)
2. Others also enter contract by creating gift (done)
3. The previous entrant will give gift to new entrant (done)
4. Assign the new entrant the ownership of the gift struct (done)
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
    //make private later
    mapping(address => giftStruct) public giftOwnershipMapping;
    //gift giving mapping
    mapping(address => address) giftDestinationMapping;
    //mapping used to order entrants
    mapping(address => uint) rankMapping;
    //arrays
    address[] private groupParticipantsArray;
    //Guard
    address private GUARD;
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
        
        address prevEntrant = _findPrevEntrant(msg.sender);
        address lastEntrant = _findPrevEntrant(GUARD);
        
        //new entrant goes after previous entrant instead of before
        giftOwnershipMapping[msg.sender] = giftOriginatorMapping[prevEntrant];
        //give santa (first entrant) the gift of the last entrant
        giftOwnershipMapping[santa] = giftOriginatorMapping[lastEntrant];
        //increment counter
        arbitraryCounter++;
    }
    
    //On Christmas day (or any arbitrary date), reveal to entrant the gift they received!
    //have individual enter their address and return the gift Struct!
    
    function giftReveal(address _myAddress) public view returns(giftStruct memory){
        require(msg.sender == _myAddress, "HEY! This isn't you. Don't make me give you coal...");
        require(block.timestamp == endTime);
        
        return giftOwnershipMapping[_myAddress];
        
    }
    
    
    //helper functions
    function getGroupParticipants() public view returns(address[] memory){
        return groupParticipantsArray;
        
    }
    
    function _verifyIndex(address prevAddress, uint256 newValue, address nextAddress) 
        internal 
        view 
        returns(bool) {
            return (prevAddress == GUARD || rankMapping[prevAddress] <= newValue) && 
                   (nextAddress == GUARD || newValue < rankMapping[nextAddress]);

    }

    //returns the index of the value, which is an address
    //adds new entrant to bottom of mapping
    function _findIndex(uint256 newValue) 
        internal 
        view 
        returns(address _candidateAddress) {
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
  
    function _findPrevEntrant(address _address) internal view returns(address) {
        
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
  
}
