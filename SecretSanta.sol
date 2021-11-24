/*
New Flow:
1. Enter into contract by creating gift (done)
2. Others also enter contract by creating gift (done)
3. The previous entrant will give gift to new entrant (done)
4. Assign the new entrant the ownership of the gift struct (done)
5. When the timer expires, previous entrant sends eth value to new entrant
6. the new entrant get's access (visually on webpage) to the gift and has the option to purchase with newly received eth!

Two design patterns:
1. interface and inheretance
2. Oracles
3. External function alls
    
To Dos:
1. Create events interface 
    A) When address enters the contract
2. Create contract interface
3. Allow new entrant to input usd and have the app convert usd to wei
    
    
Chainlink price Data
https://blog.chain.link/fetch-current-crypto-price-data-solidity/
KOVAN faucet
https://faucets.chain.link/
https://ethdrop.dev/
MM add: 0xb89A6890142B12aC79Ad27b481B8c3BfCBC711e5
Chainlink returns USD * 10^8

Gotcha notes on Chainlink:
1. I need to initialize chainlink data in constructor because it is asyncrhonous
2. I can calculate budgetCapUSD, but I need to make sure the division does not result in fraction/decimals
    A) Solidity cannot handle that. 
    B) Therefore, I convert the USD into wei first before multiplying by 20USD

*/

pragma solidity 0.8.6;

// 434110000000

// SPDX-License-Identifier: MIT

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//this will be my chainlink data (base) contract
// any security risks?
contract priceConsumerVSanta{
// contract PriceConsumerV3 {

    event budgetCapEvent(uint _budgetCap);

    AggregatorV3Interface internal priceFeed;
    uint constant weiAmt = 10**18;
    int public latestEthUSD;
    uint public budgetCapUSD;
    uint public usdInWei;
    uint constant public twentyUSD = 20;
    


    /**
     * Network: Kovan
     * Aggregator: ETH/USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        
         (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        latestEthUSD = price;

        //convert 1 usd into wei to make division possible (not fraction)
        usdInWei = (weiAmt * (10**8)) / uint(latestEthUSD);
        //convert 20usd to wei
        budgetCapUSD = twentyUSD * usdInWei;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() external {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        latestEthUSD = price;
    }
    
    //helper function
    function budgetEvaluator() private view returns(bool) {
        return(budgetCapUSD == 0);
    }
}

interface EventsInterface {
     struct giftStruct{
        string giftName;
        uint giftValue;
        string giftUrl;
    }
    
    event giftOriginated(address _giftOriginator, giftStruct _gift, address _giftRecipient);
}

interface SecretSantaInterface is EventsInterface{
    function enterSecretSanta(string memory _giftName, string memory _giftUrl) external payable;
    function giftReveal(address _myAddress) external view returns(giftStruct memory);
    function getGroupParticipants() external view returns(address[] memory);
    //no need to put internal interfaces 

}

contract SecretSanta is SecretSantaInterface, priceConsumerVSanta{
    
    
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
    
    //constructor where first entrant (Santa) needs to particpate too
    constructor(string memory _firstGiftName, string memory _firstGiftUrl) public payable {
        require(msg.value > 0 wei, "C'mon Santa...you gotta pay up too!");
        //arbitrary endTime (1 minute fore now)
        endTime = block.timestamp + 60;
        
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
        require(msg.sender == santa, "Only Santa can call this!");
        _;
    }
    
    
    modifier oneEntryOnly() {
        //hacky way to ensure user is not already in contract. Maybe think of something else
        require(giftOriginatorMapping[msg.sender].giftValue == 0, "Already in secret santa!");
        _;
    }
    
    modifier minValue() {
        //10usd minimum
        require(msg.value > (10 * usdInWei), "10USD minimum");
        _; 
    }
    modifier maxValue() {
        require(msg.value <= budgetCapUSD, "Value is too high! This is a reasonable secret santa");
        _;
    }
    
    modifier endTimeReached(){
        require(block.timestamp < endTime, "You missed your chance!");
        _;
    }
    
    function enterSecretSanta(string memory _giftName, string memory _giftUrl) 
    override 
    public 
    payable 
    oneEntryOnly
    minValue 
    maxValue 
    endTimeReached{
        require(msg.value > 0 wei, "You need more than zero to enter secret santa!");
      
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
        
        //emit 
        emit giftOriginated(msg.sender, newGiftStruct, prevEntrant);
        
        //increment counter
        arbitraryCounter++;
    }
    
    //On Christmas day (or any arbitrary date), reveal to entrant the gift they received!
    //have individual enter their address and return the gift Struct!
    
    function giftReveal(address _myAddress) override public view returns(giftStruct memory){
        require(msg.sender == _myAddress, "HEY! This isn't you. Don't make me give you coal...");
        require(block.timestamp >= endTime, "HEY! It's not Christmas yet...be patient");
        
        return giftOwnershipMapping[_myAddress];
        
    }
    
    
    //helper functions
    function getGroupParticipants() override public view returns(address[] memory){
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
    
    //external functions
    //priceConsumerVSanta address: 0x2d949Bed8Ecdf807A1366aaa7CF707665B0f08Aa
    //^^This changes each time contract is redeployed in remix
    //In mainnet (or testnet), you can use the permanetly deployed contract
    function getUpdatedEthPrice(priceConsumerVSanta _contractAddress) public onlySanta{
        _contractAddress.getLatestPrice();
    }
   
  
}
