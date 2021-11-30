## Deployed Live Site URL
https://final-proj-con-brando.netlify.app/

## How to run locally
### Prerequisites
* Node JS >= v14.17.6
* Truffle and Ganache
* Solc 0.8.10 (solidity compiler)
### Contract
* Deploy your instance of contract in Remix (injected Web3)
### Front End
* Copy address of remix deployed instance of secret secret santa
* Copy the ABI of the contract code from remix and put it into dAPP.js
* Download files onto local computer
* Go to "FrontEnd" directory (cd FrontEnd in terminal)
* Open http://localhost:8080

## Screencast link
https://www.loom.com/share/7335c07f5b8943149141104650b5ee93

## Public ethereum address for certification
* Can I provide at a later date?

## Project Description
Hohoho! It's that time again! Tis the season for getting, but more importantly, GIVING! We know saying: "It's the heart that counts" and now you have a chance to put that into action! Give a cool gift "secretly" with this dAPP!

Here's how it works: A new particpant becomes eligible to receive a gift AFTER that participant submits their own gift to give! To submit a gift, the participant will provide the gift name, the value of the gift in ETH, and a (hopefully valid) URL for the gift _(Note: Please don't go to the URL for the final project version, just ignore it)_. When that submission (transaction) is successful, they will be eligible to receive a "random" gift from another "random" participant.

IMPORTANT: You can only enter your address ONCE. Otherwise, you get coal in the form of wasted gas fees :P

*(Disclaimer: In the REAL version, you won't be able to see your gift until Christmas time. Trust me, It'll work! Also, the gift limit will be $20 USD, and not the 1 Eth in the final project version thanks to help from oracles.)*

## Simple Workflow
1. Enter website
2. Login with MetaMask
3. Fill out the 3 input fields (the value field needs to be between 1 wei and 1 eth)
4. Submit
5. If submission is successful, press the gift reveal to see what gift you recevied from your SECRET SANTA! HOHOHO!

## Directory Structure
* FrontEnd: Project's front end
* tut/contracts: Smart contracts deployed on the Rinkeby network
* tut/migrations: Migration files for deploying contracts in contracts directory
* tut/test: Tests for smart contracts.
