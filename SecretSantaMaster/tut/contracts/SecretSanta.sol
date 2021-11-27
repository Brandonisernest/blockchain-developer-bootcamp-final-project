/*
-----
THIS VERSION WILL NOT USE ORACLES. 
I HAD DIFFICULTY PERFORMING UNIT TESTS WITH ORACLES GIVEN THE ASYNC NATURE
THIS VERSION WILL ONLY REQUIRE 1 WEI ENTRY 
-----
New Flow:
1. Enter into contract by creating gift (done)
2. Others also enter contract by creating gift (done)
3. The previous entrant will give gift to new entrant (done)
4. Assign the new entrant the ownership of the gift struct (done)
5. When the timer expires, previous entrant sends eth value to new entrant
6. the new entrant get's access (visually on webpage) to the gift and has the option to purchase with newly received eth!

//Checklist

Commented to NatSpec? TBD

Two design patterns:
1. interface and inheretance - done
2. Access Control Design Patterns (Restricted Access - Only Santa) - done

Attack Vectors: Go through this more carefully
1. Using specific pragma - done
2. Proper use of require - done
3. Use modifiers only for validation - done
4. Cause Effect interactions (giftReveal() - guarded against re-entrancy) - done

Inheriting from at least 1 interface - done

Easily compiled - done
    
*/

pragma solidity 0.8.10;


interface EventsInterface {
     struct giftStruct{
        string giftName;
        uint giftValue;
        string giftUrl;
    }
    
    event giftOriginated(address _giftOriginator, giftStruct _gift, address _giftRecipient);
    event giftRevealed(giftStruct);
}

interface SecretSantaInterface is EventsInterface{
    function enterSecretSanta(string memory _giftName, string memory _giftUrl) external payable;
    function giftTransfer(address _myAddress) external payable;
    function giftReveal(address _myAddress) external view returns(giftStruct memory);
    function getGroupParticipants() external view returns(address[] memory);
    function getGiftName(address _address) external view returns(uint);

}

contract SecretSanta is SecretSantaInterface{
    
    //owner of the contract. In case for permissioning
    address public santa;
    //time when entrants are barred from entering and when gifts get distributed
    uint public endTime;
    //who created the gift struct
    mapping(address => giftStruct) public giftOriginatorMapping;
    //who currently owns the gift Struct
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
    //security mapping for cause-effect interaction
    mapping(address => bool) public giftRevealMapping;  
    
    //constructor where first entrant (Santa) needs to particpate too
    constructor(string memory _firstGiftName, string memory _firstGiftUrl) payable {
        require(msg.value >= 1 wei, "C'mon Santa...you gotta pay up too!");
        //maximum 1 ether 
        require(msg.value <= 1 ether, "Value is too high! This is a reasonable secret santa");
        //Real dAPP would end on Christmas (estimated block height or oracle)
        endTime = block.timestamp + 60;
        
        //Deployer is the first entrant (santa)
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
        //increment counter used to order entrants in linkedlist
        arbitraryCounter++;
    }

    //permissioning modifier
    modifier onlySanta() {
        require(msg.sender == santa, "Only Santa can call this!");
        _;
    }
    
    function enterSecretSanta(string memory _giftName, string memory _giftUrl) 
    override 
    public 
    payable {
        //hacky way to ensure user is not already in contract. Maybe think of something else
        require(giftOriginatorMapping[msg.sender].giftValue == 0, "Already in secret santa!");
        //10usd minimum
        require(msg.value >= 1 wei, "1 Wei minimum");
        //maximum 1 ether 
        require(msg.value <= 1 ether, "Value is too high! This is a reasonable secret santa");
        //close access on set date
        // require(block.timestamp < endTime, "You missed your chance!");
        
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
        //set new entrant to true. Used to prevent re-entrancy
        giftRevealMapping[msg.sender] = true;
        giftRevealMapping[santa] = true;
        
        //emit 
        emit giftOriginated(msg.sender, newGiftStruct, prevEntrant);
        
        //increment counter
        arbitraryCounter++;
    }
    
    //On Christmas day (or any arbitrary date), reveal to entrant the gift they received!
    //have individual enter their address and return the gift Struct!
    function giftTransfer(address _myAddress) override public payable{
        //only address owner can call this, implying they need to be in the contract
        require(msg.sender == _myAddress, "HEY! This isn't you. Don't make me give you coal...");
        //can't reveal gift before "Christmas"!
        // require(block.timestamp >= endTime, "HEY! It's not Christmas yet...be patient");
        require(giftRevealMapping[_myAddress] == true, "Don't commit a re-entrancy attack!");
        //implement "cause-effect-interactions"
        //set bool to false to prevent re-entrancy
        giftRevealMapping[_myAddress] = false;
        //transfer funds to address
        (bool sent, bytes memory data) = _myAddress.call{value : giftOwnershipMapping[_myAddress].giftValue}("");
        //throw error if funds were not transfered
        require(sent, "Failed to transfer funds");
    }


    ///argh....i need to have my return functions ONLY be view
    function giftReveal(address _myAddress) override public view returns(giftStruct memory){

        require(msg.sender == _myAddress, "HEY! This isn't you. Don't make me give you coal...");
        //can't reveal gift before "Christmas"!
        // require(block.timestamp >= endTime, "HEY! It's not Christmas yet...be patient");
        return giftOwnershipMapping[_myAddress];
    }
    
    
    //helper functions
    function getGroupParticipants() override public view returns(address[] memory){
        return groupParticipantsArray;
        
    }

    //mainly for testing purposes
    function getGiftName(address _address) override public view returns(uint){
        return giftOwnershipMapping[_address].giftValue;

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

    //only santa can check on the balance. 
    function checkContractBalance() public view onlySanta returns(uint){
        return address(this).balance;
    }

    //get endTime for front end
    function getEndTime() public view returns(uint){
        return endTime;
    }
    
}