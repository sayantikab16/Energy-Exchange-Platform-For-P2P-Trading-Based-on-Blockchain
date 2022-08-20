const ExchangePlatform = artifacts.require("ExchangePlatform");

module.exports = function(deployer) {
  deployer.deploy(ExchangePlatform);
};
