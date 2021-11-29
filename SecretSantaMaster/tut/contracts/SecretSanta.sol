// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;


/// @title Interface for SecretSanta contract containing events!
/// @author Brandon
/// @notice Contains events to emit information about relevant gifts to end user
/// @dev Declaring the giftSruct struct here in order to include in downstream interfaces/contracts

interface EventsInterface {
     struct giftStruct{
        string giftName;
        uint giftValue;
        string giftUrl;
    }
    
    /// @notice Emitted when a user successfully participates in secret santa
    /// @param _giftOriginator address of new participant
    /// @param _gift information of gift in struct form (name, value, url)
    /// @param _giftRecipient address of the gift giver to the new participant
    event giftOriginated(address _giftOriginator, giftStruct _gift, address _giftRecipient);
    
    /// @notice Emitted when participant chooses to reveal their incoming gift
    /// @param _gift information of gift in struct form (name, value, url)
    event giftRevealed(giftStruct _gift);
}

/// @title Interface for main SecretSanta contract!
/// @author Brandon
/// @notice Contains events to emit information about relevant gifts to end user
/// @dev Function explanations in SecretSanta contract
interface SecretSantaInterface is EventsInterface{

    function enterSecretSanta(string memory _giftName, string memory _giftUrl) external payable;
    function giftTransfer(address _myAddress) external payable;
    function giftReveal(address _myAddress) external view returns(giftStruct memory);

}

/// @title Contract for decentralized Secret Santa!
/// @author Brandon
/// @notice Allows participant to either keep the gift value in eth or redeem the item by following a gift URL 
/// @dev Designed to allow oracle price information (i.e. Chainlink)

contract SecretSanta is SecretSantaInterface{
    
    /// @notice Owner of the contract. In case for permissioning
    address public santa;

    /// @notice Time when entrants are barred from entering and when gifts get distributed
    /// @dev For final proj version, this is not used so we can demonstrate full functionality
    uint private endTime;

    /// @notice Mapping that shows who created the gift struct
    mapping(address => giftStruct) private giftOriginatorMapping;

    /// @notice Mapping that shows who currently owns a particular gift Struct
    /// @dev This is used to "assign" gift recipients
    mapping(address => giftStruct) private giftOwnershipMapping;

    /// @notice Linked list mapping that points last entrant to newest entrant
    /// @dev This is used to create a closed loop to pass gifts around
    mapping(address => address) giftDestinationMapping;
    
    /// @notice mapping used to order/rank entrants in the giftDestinationMapping;
    /// @dev Used in conjuction with giftDestinationMapping and arbitraryCounter to ensure gift gets passed around in sequential order
    mapping(address => uint) rankMapping;

    /// @notice Array of all participants
    /// @dev Used for QA purposes
    address[] private groupParticipantsArray;

    /// @notice To create header and footer guard for the linked list
    address private GUARD;

    /// @notice arbitrary counter for giftDestinationMapping
    uint arbitraryCounter = 0;

    /// @notice Security mapping for cause-effect interaction
    /// @dev Used to protect against re-entrancy
    mapping(address => bool) private giftRevealMapping;  
    
    /// @notice constructor where first entrant (Santa) needs to particpate too
    /// @notice All participants, even Santa, needs to pay minimum
    /// @notice This SecretSanta is meant to invite all-comers. Therefore, the price can't be too high.
    /// @param _firstGiftName Name of initial gift
    /// @param _firstGiftUrl URL of initial gift
    /// @dev There needs to be an initial gift in the contract for link list to work properly. Contract deployer will have that responsibility
    /// @dev The participant's msg.value will be the giftValue of the giftStruct
    /// @dev In version with oracle, the max value would be $20USD or something like thats
    /// @dev endTime not used in final proj version. Real dAPP would end on Christmas. Also, likely not based off block.timestamp.
    /// @dev arbitraryCounter needs to be incremented after EVERY new particpant (Santa included)
    constructor(string memory _firstGiftName, string memory _firstGiftUrl) payable {
        require(msg.value >= 1 wei, "C'mon Santa...you gotta pay up too!");
        require(msg.value <= 1 ether, "Value is too high! This is a reasonable secret santa");
        endTime = block.timestamp + 60;
        santa = msg.sender;
        GUARD = santa;
        giftDestinationMapping[GUARD] = GUARD;
        groupParticipantsArray.push(santa);
    
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
    
    /// @notice Function called to enter contract and particpate in Secret Santa
    /// @param _giftName Name of new gift
    /// @param _giftUrl URL of new gift
    /// @dev Require statements ensure user is not already in contract and establish min and max values
    /// @dev Creates new giftStruct, places it into respective mappings and arrays, updates linked list
    /// @dev Logic assigns previous entrant's gift to be given to new entrant
    function enterSecretSanta(string memory _giftName, string memory _giftUrl) 
    override 
    public 
    payable {
        require(giftOriginatorMapping[msg.sender].giftValue == 0, "Already in secret santa!");
        require(msg.value >= 1 wei, "1 Wei minimum");
        require(msg.value <= 1 ether, "Value is too high! This is a reasonable secret santa");
        
        giftStruct memory newGiftStruct = giftStruct({
            giftName : _giftName,
            giftValue : msg.value,
            giftUrl : _giftUrl
        });
        
        giftOriginatorMapping[msg.sender] = newGiftStruct;
        groupParticipantsArray.push(msg.sender);
        
        address index = _findIndex(arbitraryCounter);
        giftDestinationMapping[msg.sender] = giftDestinationMapping[index];
        giftDestinationMapping[index] = msg.sender;
        
        address prevEntrant = _findPrevEntrant(msg.sender);
        address lastEntrant = _findPrevEntrant(GUARD);

        giftOwnershipMapping[msg.sender] = giftOriginatorMapping[prevEntrant];
        giftOwnershipMapping[santa] = giftOriginatorMapping[lastEntrant];

        giftRevealMapping[msg.sender] = true;
        giftRevealMapping[santa] = true;
    
        emit giftOriginated(msg.sender, newGiftStruct, prevEntrant);
        arbitraryCounter++;
    }
    

    /// @notice Transfers giftValue of the giftStruct to be received
    /// @param _myAddress address of partipant (your address)
    /// @dev giftRevealMapping bool updated to prevent re-entrancy
    function giftTransfer(address _myAddress) override public payable{
        require(msg.sender == _myAddress, "HEY! This isn't you. Don't make me give you coal...");
        require(giftRevealMapping[_myAddress] == true, "Don't commit a re-entrancy attack!");

        giftRevealMapping[_myAddress] = false;

        (bool sent, bytes memory data) = _myAddress.call{value : giftOwnershipMapping[_myAddress].giftValue}("");
        require(sent, "Failed to transfer funds");
    }


    /// @notice Reveals the giftStruct (name, value, url)
    /// @param _myAddress address of partipant (your address)
    function giftReveal(address _myAddress) override public view returns(giftStruct memory){
        require(msg.sender == _myAddress, "HEY! This isn't you. Don't make me give you coal...");
        return giftOwnershipMapping[_myAddress];
    }
    

    /// @notice The following functions are helper functions
    
    /// @notice get array of all participating addresses
    function getGroupParticipants() public view returns(address[] memory){
        return groupParticipantsArray;
        
    }

    /// @notice Get just the value of the gift you will receive
    /// @param _address Address you want to check
    /// @dev Mainly for unit testing purposes
    /// @dev Originally checks .giftName, but changed for unit testing. Can be flexible
    function getGiftName(address _address) public view returns(uint){
        return giftOwnershipMapping[_address].giftValue;

    }
    
    /// @notice Checks if incoming value belongs between 2 existing, ranked values
    /// @param prevAddress previous address of linked list
    /// @param newValue arbitraryCounter value assigned to each new gift
    /// @param nextAddress nextAddress on the linked list
    function _verifyIndex(address prevAddress, uint256 newValue, address nextAddress) 
        internal 
        view 
        returns(bool) {
            return (prevAddress == GUARD || rankMapping[prevAddress] <= newValue) && 
                   (nextAddress == GUARD || newValue < rankMapping[nextAddress]);

    }

    /// @notice Returns the index of the value, which is an address, for linked list
     /// @param newValue arbitraryCounter value assigned to each new gift
    /// @dev Adds new entrant to bottom of mapping instead of top
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
    
    /// @notice Checks if the an address preceeds another adddress
    /// @param _address Address in question
    /// @param _prevEntrant Previous address in question
    function _isPrevEntrant(address _address, address _prevEntrant) internal view returns(bool) {
        return giftDestinationMapping[_prevEntrant] == _address;
    }
  
    /// @notice Finds the previous address in the linked list for a given address
    /// @param _address Address in question
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

    /// @notice Check total balance of contract
    /// @dev Only santa can check on the balance
    function checkContractBalance() internal view onlySanta returns(uint){
        return address(this).balance;
    }

    /// @notice Get endTime for uint testing purposes
    /// @dev Used mainly to see if entTime can get passed from contract to JS
    function getEndTime() internal view returns(uint){
        return endTime;
    }
    
}
