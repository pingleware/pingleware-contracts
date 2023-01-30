var NewsFeed = artifacts.require('./NewsFeed');

module.exports = function(deployer, network, accounts) {
    if (network == "nodeploy") return;
    deployer.deploy(NewsFeed);
}
