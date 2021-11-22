/*
General walkthrough

**Secret Santa NOT White Elephant

1. Pay to enter Main Secret Santa Smart contract
2. The floor price needs $20 USD (0.004803 Ether as of 11/30) - implement oracle? - Chainlink for Eth price?
    A) https://www.google.com/search?q=how+to+use+chainlink+oracle+in+solidity&oq=how+to+use+chainlink+oracle+in+solidity&aqs=chrome..69i57.6921j0j1&sourceid=chrome&ie=UTF-8
3. When you enter Main Secret Santa Smart contract, it will place you in a struct based on price range (santa Struct?)
4. Important! When you enter a santa struct, ALL you need to enter and specify are the gift name, value of the gift at time of struct creation, link to the gift (limit to amazon) 
    A) Right now, I want to not actually send the "gift" but the gift value!
    B) The information provided (i.e. gift name....it creates a gift Struct)
    C) price value will put you in mapping
5. No limit to entrants to a group. 
6. Within the santa Struct, include:
    A) Gift Struct
    B) Mapping with price range to Gift Struct
    C) Mapping with address to Gift Struct
        a) Only allow one address to enter one gift struct for now
7. Gift struct:
    A) Name of Gift
    B) Value of Gift
    C) Link of Gift
    D) Based on value of Gift, address is assigned group number
9. After a certain time (block height)has passed and only one person is in a group struct, close out the struct and allow the addresses to enter into a new struct with new price
10. Pseudorandomly assign gift to each person
    A) Make sure the person can't give gift to themselves
    B) Distribute gift once timer ends
11. Allow person to choose to either receive the gift or just keep the cash value
12. You transfer ownership of giftStruct via Mapping
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
    //who created the gift struct?
    mapping(address => giftStruct) public giftOriginatorMapping;
    //who owns the gift Struct
    mapping(address => giftStruct) giftOwnershipMapping;
    //what address belongs to what group based on giftValue
    mapping(address => uint) public groupMapping;
    //arrays
    address[] public groupOneArray;
    address[] public groupTwoArray;
    address[] public groupThreeArray;
    
    struct giftStruct{
        string giftName;
        uint giftValue;
        string giftUrl;
        uint groupNumber;
    }
    
    constructor() public {
        santa = msg.sender;

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
        require(msg.value < 90 ether, "Value is too high! This is a reasonable secret santa");
        _;
    }
    
    function enterSecretsanta(string memory _giftName, string memory _giftUrl) public payable oneEntryOnly maxValue {
        require(msg.value > 0 ether, "You need more than zero to enter secret santa!");
        uint _groupNumber;
        
        // uint giftValueEth = msg.value * 1 ether;
        
        if(msg.value >= 1 ether && msg.value < 5 ether){
            _groupNumber = 1;
            groupOneArray.push(msg.sender);
        }
        else if (msg.value >= 5 ether && msg.value < 10 ether){
            _groupNumber = 2;
            groupTwoArray.push(msg.sender);
        }
        else {
            _groupNumber = 3;
            groupThreeArray.push(msg.sender);
        }
        
        //front end will require just these inputs
        giftStruct memory newGiftStruct = giftStruct({
            giftName : _giftName,
            giftValue : msg.value,
            giftUrl : _giftUrl,
            groupNumber : _groupNumber
        });
        
        //add to giftOriginatorMapping;
        giftOriginatorMapping[msg.sender] = newGiftStruct;
        
        //assign msg.sender a group number (based on value)
        groupMapping[msg.sender] = _groupNumber;
        
    }
    
    //helper function
    function getGroupParticipants(uint _groupNumber) public view returns(address[] memory){
        if(_groupNumber == 1){
            return groupOneArray;
        }
         else if(_groupNumber == 2){
            return groupTwoArray;
        }
         else if (_groupNumber == 3){
            return groupThreeArray;
        }
        
    }
    
}
