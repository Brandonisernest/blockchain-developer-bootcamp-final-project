/*
General walkthrough
**Secret Santa NOT White Elephant
1. Pay to enter Main Secret Santa Smart contract
    A) for this version, make it a humble secret santa...not everybody is rich!
    B) 10 eth limit
2. The floor price needs $20 USD (0.004803 Ether as of 11/30) - implement oracle? - Chainlink for Eth price?
    A) https://www.google.co
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
    mapping(address => giftStruct) giftOwnershipMapping;

    //arrays
    address[] public groupParticipantsArray;
    
    struct giftStruct{
        string giftName;
        uint giftValue;
        string giftUrl;
    }
    
    constructor() public {
        santa = msg.sender;
        //arbitrary endTime
        endTime = block.timestamp * 2;
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
        require(block.timestamp <= endTime, "You missed your chance!");
        _;
    }
    
    function enterSecretsanta(string memory _giftName, string memory _giftUrl) public payable oneEntryOnly maxValue endTimeReached{
        require(msg.value > 0 ether, "You need more than zero to enter secret santa!");
      
        //front end will require just these inputs
        giftStruct memory newGiftStruct = giftStruct({
            giftName : _giftName,
            giftValue : msg.value,
            giftUrl : _giftUrl
        });
        
        //add to giftOriginatorMapping;
        giftOriginatorMapping[msg.sender] = newGiftStruct;
        
        
    }
    
    //santa distributes gift one endTime has passed
    function distributeGifts() public payable onlySanta{
        require(block.timestamp > endTime);
        
        
    }
    
    //helper function
    function getGroupParticipants() public view returns(address[] memory){
        return groupParticipantsArray;
        
    }
    
}
