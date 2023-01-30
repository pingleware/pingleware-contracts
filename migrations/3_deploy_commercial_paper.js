var CommercialPaperToken = artifacts.require('./CommercialPaperToken');

module.exports = function(deployer, network, accounts) {
    if (network == "nodeploy") return;
    deployer.deploy(CommercialPaperToken);
}
