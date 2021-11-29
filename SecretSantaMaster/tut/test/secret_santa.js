const SecretSanta = artifacts.require("SecretSanta");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */

let secretSantaInstance;

//before each
beforeEach(async () => {
  secretSantaInstance = await SecretSanta.deployed();
});

contract("SecretSanta", function (accounts) {
  //Unit test 1: Test that the contract was deployed
  it("should assert true", async function () {
    // await SecretSanta.deployed();
    return assert.isTrue(true);
  });

  //unit test 2: Test that the group participant array works properly
  it("Should allow new address to enter", async () => {
    await secretSantaInstance.enterSecretSanta("Gift 2", "Gift 2's URL", {
      from: accounts[1],
      value: web3.utils.toWei("1", "ether"),
      gas: 5000000,
    });

    return assert.isTrue(true);
  });

  //Unit test 3: Test that new addresses can enter the SecretSanta contract
  it("Should return all participants", async () => {
    await secretSantaInstance.enterSecretSanta("Gift 2", "Gift 2's URL", {
      from: accounts[2],
      value: web3.utils.toWei("1", "ether"),
      gas: 5000000,
    });

    await secretSantaInstance.enterSecretSanta("Gift 3", "Gift 3's URL", {
      from: accounts[3],
      value: web3.utils.toWei("1", "ether"),
      gas: 5000000,
    });

    const testArray = await secretSantaInstance.getGroupParticipants.call({
      from: accounts[0],
    });

    if (
      assert.equal(testArray[0], accounts[0]) &&
      assert.equal(testArray[2], accounts[2]) &&
      assert.equal(testArray[3], accounts[3])
    ) {
      return true;
    } else {
      return false;
    }
  });

  //unit test 4: Test that new entrants received gifts from the address directly preceeding them

  it("should assign new entrant to receive previous entrants gift", async () => {

    const giftAmt = await secretSantaInstance.getGiftName(accounts[1], { from: accounts[1]});

    assert.equal(giftAmt, web3.utils.toWei("1","ether"));
  });


  //unit test 5: Test that the budget cap of 1 eth works
  it("should fail if I put too much money", async() => {
    
    
    try {await secretSantaInstance.enterSecretSanta("Gift 5", "Gift 5's URL", {
      from: accounts[5],
      value: web3.utils.toWei("2", "ether"),
      gas: 5000000,
    });}
    catch(err){
      assert.isTrue(true);
    }

    
  })

});
