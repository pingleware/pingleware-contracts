var PRESSPAGE506C = artifacts.require('./PRESSPAGE506C');

module.exports = function(deployer, network, accounts) {
    if (network == "nodeploy") return;
    deployer.deploy(PRESSPAGE506C);
}
