//Pro tip...inspect page -> network -> disable cache
//^^ This allows page to properly reflect changes made to js

/*
Instructions for final version webcast
1) Remove the need for "end time". 
2) Explain that the actually dAPP would be deployed for a Christmas "endtime". 
    - After the demo, I will set to Christmas
3) Deploy in remix (copy that contract address and ABI of santa contract). MUST BE INJECTED WEB3
	- Regularly remix deployment is limited to a private instance and cannot be accessed by MM addresses
4) You need an instance of web3 (I used this:  "https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js")

*/

//detected MM
//The VERY first thing we want in our dAPP is to see if we are connected to a web3 provider
//in our case, we are using MM
window.addEventListener('load', function() {
    if(typeof window.ethereum !== 'undefined'){
        console.log("MetaMask detected!")
        let mmDetected = getElementById = document.getElementById("mm-detected");
        mmDetected.innerHTML = "MetaMask has been detected!"
    }
    else {
        console.log("Theres no wallet! Not Available!");
        alert("You need to install MetaMask or another wallet!");
    }
});

//connect MM on click!
const mmEnable = document.getElementById("mm-connect-btn");

mmEnable.onclick = async() => {
    await ethereum.request({ method: "eth_requestAccounts"});

    //get current account
    const mmCurrentAccount = document.getElementById("mm-current-account");
	console.log(mmCurrentAccount);

    mmCurrentAccount.innerHTML = "Here's your current account" + ethereum.selectedAddress;
}


//remix contract address deployed on rinkeby
const ssAddress = "0x194954ecF4cE2c79B9448378879Db544eb8053cA";

//get the ABI from remix
const ssABI = [
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_firstGiftName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_firstGiftUrl",
				"type": "string"
			}
		],
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "_giftOriginator",
				"type": "address"
			},
			{
				"components": [
					{
						"internalType": "string",
						"name": "giftName",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "giftValue",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "giftUrl",
						"type": "string"
					}
				],
				"indexed": false,
				"internalType": "struct EventsInterface.giftStruct",
				"name": "_gift",
				"type": "tuple"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "_giftRecipient",
				"type": "address"
			}
		],
		"name": "giftOriginated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "giftName",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "giftValue",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "giftUrl",
						"type": "string"
					}
				],
				"indexed": false,
				"internalType": "struct EventsInterface.giftStruct",
				"name": "",
				"type": "tuple"
			}
		],
		"name": "giftRevealed",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "checkContractBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "endTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_giftName",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_giftUrl",
				"type": "string"
			}
		],
		"name": "enterSecretSanta",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getEndTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_address",
				"type": "address"
			}
		],
		"name": "getGiftName",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getGroupParticipants",
		"outputs": [
			{
				"internalType": "address[]",
				"name": "",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "giftOriginatorMapping",
		"outputs": [
			{
				"internalType": "string",
				"name": "giftName",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "giftValue",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "giftUrl",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "giftOwnershipMapping",
		"outputs": [
			{
				"internalType": "string",
				"name": "giftName",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "giftValue",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "giftUrl",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_myAddress",
				"type": "address"
			}
		],
		"name": "giftReveal",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "giftName",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "giftValue",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "giftUrl",
						"type": "string"
					}
				],
				"internalType": "struct EventsInterface.giftStruct",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "giftRevealMapping",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_myAddress",
				"type": "address"
			}
		],
		"name": "giftTransfer",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "santa",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]


////
////
////
//mapping html elements
const enterSantaBtn = document.getElementById("enter-santa");
const giftNameField = document.getElementById("gift-name-input");
const giftValueField = document.getElementById("gift-value-input");
const giftURLField = document.getElementById("gift-URL-input");
const giftRevealBtn = document.getElementById("gift-reveal");
//gift reveal section
const giftRevealSection = document.getElementById("gift-reveal-section");

//functions
const enterSantaBtnHandler = async() => {
    const giftName = giftNameField.value;
    const giftValue = giftValueField.value;
    const giftURL = giftURLField.value;
    console.log(`Gift Name: ${giftName}, Gift Value: ${giftValue}, Gift URL: ${giftURL}`);

    //submit transaction to enter contract

    //instantiate web3 (avoid doing so globally)
    const web3 = new Web3(window.ethereum);

    //instance of the secret santa (ssABI and ssAddress declared above)
    const secretSanta = new web3.eth.Contract(ssABI, ssAddress);
    
    //remember that window.ethereum IS MetaMask
    secretSanta.setProvider(window.ethereum);

	await secretSanta.methods.enterSecretSanta(giftName, giftURL)
    .send( {from : ethereum.selectedAddress,
            value: web3.utils.toWei(giftValue, "ether"),
            gas: 5000000 });

}


const giftRevealBtnHandler = async() => {

	//submit transaction to enter contract

    //instantiate web3 (avoid doing so globally)
    const web3 = new Web3(window.ethereum);

    //instance of the secret santa (ssABI and ssAddress declared above)
    const secretSanta = new web3.eth.Contract(ssABI, ssAddress);
    
    //remember that window.ethereum IS MetaMask
    secretSanta.setProvider(window.ethereum);

	//transfer funds
	await secretSanta.methods.giftTransfer(ethereum.selectedAddress)
	.send( {from: ethereum.selectedAddress,
			gas: 5000000})

	//gift reveal
	const giftRevealElem = await secretSanta.methods.giftReveal(ethereum.selectedAddress)
    .call( {from : ethereum.selectedAddress});
	
	//output message
	alert(`Your gift is: ${giftRevealElem[0]}. 
	It is worth ${giftRevealElem[1]} Wei. You should now have this in your address' wallet. 
	If you choose to redeem, go to this link: ${giftRevealElem[2]}`);
}

//event listeners
enterSantaBtn.addEventListener("click", enterSantaBtnHandler);
giftRevealBtn.addEventListener("click", giftRevealBtnHandler);

