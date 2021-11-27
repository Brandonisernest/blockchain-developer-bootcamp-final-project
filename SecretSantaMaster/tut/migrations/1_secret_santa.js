const SecretSanta = artifacts.require("SecretSanta");


//https://web3js.readthedocs.io/en/v1.2.11/web3-utils.html#towei


module.exports = function (deployer) {
  deployer.deploy(SecretSanta, "Gift 1", "Gift 1's URL", { value : web3.utils.toWei("1","ether") , gas: 5000000});
};
