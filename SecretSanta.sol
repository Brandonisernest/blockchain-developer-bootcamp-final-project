/*
General walkthrough

1. Pay to enter Main Secret Santa Smart contract
2. The floor price needs $20 USD (0.004803 Ether as of 11/30) - implement oracle? - Chainlink for Eth price?
    A) https://www.google.com/search?q=how+to+use+chainlink+oracle+in+solidity&oq=how+to+use+chainlink+oracle+in+solidity&aqs=chrome..69i57.6921j0j1&sourceid=chrome&ie=UTF-8
3. When you enter Main Secret Santa Smart contract, it will place you in a struct based on price range (santa Struct?)
4. Important! When you enter a santa struct, ALL you need to enter and specify are the gift name, value of the gift at time of struct creation, link to the gift (limit to amazon) 
    A) Right now, I want to not actually send the "gift" but the gift value!
    B) The information provided (i.e. gift name....it creates a gift Struct)
    C) price value will put you in mapping
5. After minimum number of address have entered santa Struct (5), prevent further entry into that struct
6. Within the santa Struct, include:
    A) Gift Struct
    B) Mapping with price range to Gift Struct
    C) Mapping with address to Gift Struct
        a) Only allow one address to enter one gift struct for now
7. Within each gift Struct:
    C) Mapping of Address => "string" home address? (optional)
    B) Uint counter for 
7. After a certain time (block height)has passed and not enough people entered a santa struct, close out the struct and allow the addresses to enter into a new struct with new price
8. Pseudorandomly assign gift to each person
    A) Make sure the person can't give gift to themselves
9. Allow person to choose to either receive the gift or just keep the cash value

*/
