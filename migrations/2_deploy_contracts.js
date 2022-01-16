// @ts-nocheck
const App = artifacts.require("App");

module.exports = async function(deployer) {
   await deployer.deploy(App);
}
