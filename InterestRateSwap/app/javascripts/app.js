import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';

import interestRateSwap_artifacts from '../../build/contracts/InterestRateSwap.json';

const idPrefix = "#cf_";

var web3;
var accountA;
var accountB;
var contractInstance;
var InterestRateSwap = contract(interestRateSwap_artifacts);

window.App = {
  start: function() {
    setWeb3Provider(InterestRateSwap);

    this.getAccounts();

    InterestRateSwap.deployed().then(_contractInstance => {
      contractInstance = _contractInstance;
      $("#cf_address").html(contractInstance.address);
      $("#qrcode").html("<img src=\"https://chart.googleapis.com/chart?cht=qr&chs=350&chl="
        +contractInstance.address+"\" height=\"350\"/>");
    });
  },

  getAccounts: function() {
    web3.eth.getAccounts((err, _accounts) => {
      accountA = _accounts[0];
      accountB = _accounts[1];
    })
  },

  refreshVars: function() {
    var addresses = ["partyA", "partyB"];
    var numerics = ["notional", "fixedRate", "floatingRateMargin", "lastAmountPaid",
                    "schedule", "startTime", "timeToExpiry"];
    var bools = ["isActive", "isComplete"];

    this.refreshAddresses(addresses);
    this.refreshNumerics(numerics);
    this.refreshBools(bools);
  },

  refreshAddresses: function(addresses) {
    for (var address of addresses)
      $(idPrefix+address).html(this.getContractVar(address));
  },

  refreshNumerics: function(numerics) {
    for (numeric of numerics)
      $(idPrefix+numeric).html(this.getContractVar(numeric).toNumber());
  },

  refreshBools: function(bools) {
    for (bool of bools)
      $(idPrefix+bool).html(getContractVar(bool) ? "True" : "False");
  },

  getContractVar: function(varName) {
    contractInstance[varName].call().then(result => {
      return {name: varName, value: result};
    });
  },

  initializeContract: function() {
    var partyATradingAcct = $("#partyATradingAcct").val();
    var partyBTradingAcct = $("#partyBTradingAcct").val();
    var fixedRate = parseFloat($("#fixedRate").val());
    var floatingRateMargin = parseFloat($("#floatingRateMargin").val());
    var notional = parseFloat($("#notional").val());
    var schedule = parseFloat($("#schedule").val());
    var rateFeed = $("#rateFeed").val();
    var feedName = $("#feedName").val();
    var timeToExpiry = parseFloat($("#timeToExpiry").val());

    this.setStatus("status", "Initiating transation... (please wait)")

    contractInstance.initialize.sendTransaction(
      partyATradingAcct,
      partyBTradingAcct,
      fixedRate,
      floatingRateMargin,
      notional,
      schedule,
      feedName,
      rateProvider,
      timeToExpiry,
      {from: accountA, gas: 2000000}).then(
        () => {
          this.refreshVars();
      });
  },

  validate: function() {
    setStatus("status1", "Initiating transaction... (please wait)");
    contractInstance.validate.sendTransaction({from: accountB, gas: 2000000}).then(
      () => {
        this.refreshVars();
    });
  },

  exercise: function() {
    setStatus("status2", "Initiating transaction... (please wait)");
    contractInstance.exercise.sendTransaction({from: accountA, gas: 2000000}).then(
      () => {
        refreshVars();
    });
  },

  setStatus: function(statusTag, message) {
    $('#'+statusTag).html(message);
  }
}

function setWeb3Provider(contract) {
  if (typeof web3 !== 'undefined')
    web3 = new Web3(web3.currentProvider);
  else
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  contract.setProvider(web3.currentProvider);
};

window.addEventListener('load', function() {

  $("#tabs").tabs();

  App.start();
});
