import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';

import calloption_artifacts from '../../build/contracts/CallOption.json';

const idPrefix = "#cf_";

var web3;
var account;
var contractInstance;
var CallOption = contract(calloption_artifacts);

function setWeb3Provider(contract) {
  if (typeof web3 !== 'undefined')
    web3 = new Web3(web3.currentProvider);
  else
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  contract.setProvider(web3.currentProvider);
};

function start() {
  getAccount();
  CallOption.deployed().then(_contractInstance => {
    contractInstance = _contractInstance;
    bindButtons();
  }).then(() => {
    $("#cf_address").html(contractInstance.address);
    $("#qrcode").html("<img src=\"http://chart.googleapis.com/chart?cht=qr&chs=350&chl="+contractInstance.address+"\" height=\"350\"/>");
    refreshVars();
  });
}

function getAccount() {
  web3.eth.getAccounts((err, accounts) => {
    if (err)
      alert("Could not get account");
    else
      account = accounts[0];
  });
}

function setStatus(message) {
  $("#status").html(message);
}

function setStatus1(message) {
  $("#status1").html(message);
}
;;function setStatus2(message) {
}

function refreshVars() {
  const boolNames = ["isActive", "isComplete"];
  const currencyNames = ["strikePrice", "premium"]
  const numericNames = ["underlyingQty", "startTime", "timeToExpiry"];
  const addressAndStringNames = ["seller", "buyer", "underlyingName"]
  
  getContractBools(boolNames);
  getContractCurrencies(currencyNames);
  getContractNumerics(numericNames);
  getContractAddressesAndStrings(addressAndStringNames);
}

function getContractBools(variableNames) {
  for (var variableName of variableNames)
    getContractVar(variableName).then(result => {
      var boolString;
      if (result.value)
        boolString = "True";
      else
        boolString = "False";
      $(idPrefix+result.name).html(boolString);
    });
}

function getContractCurrencies(variableNames) {
  for (var variableName of variableNames)
    getContractVar(variableName).then(result => {
      $(idPrefix+result.name).html(web3.fromWei(result.value.toNumber(), "ether"));
    });
}

function getContractNumerics(variableNames) {
  for (var variableName of variableNames)
    getContractVar(variableName).then(result => {
      $(idPrefix+result.name).html(result.value.toNumber());
    });
}

function getContractAddressesAndStrings(variableNames) {
  for (var variableName of variableNames)
    getContractVar(variableName).then(result => {
      $(idPrefix+result.name).html(result.value);
    });
}

function getContractVar(variableName) {
  return contractInstance[variableName].call().then(result => {
    return {name: variableName, value: result};
  });
}

function bindButtons() {
  $("#initializeBtn").click(function() {
    console.log("Running for some reason");
    var buyer = $("#buyer").val();
    var strikePrice = web3.toWei(parseFloat($("#strikePrice").val()), "ether");
    var underlyingName = $("#underlyingName").val();
    var underlyingQty = parseFloat($("#underlyingQty").val());
    var premium = web3.toWei(parseFloat($("#premium").val()), "ether");
    var timeToExpiry = parseFloat($("#timeToExpiry").val());

    setStatus("Initiating transaction... (please wait)");

    contractInstance.initialize
      .sendTransaction(buyer, strikePrice, premium, timeToExpiry, underlyingQty, underlyingName, {from:account, gas: 200000}).then(
        () => {
          refreshVars();
        });
  });

  $("#validateBtn").click(function() {
    var amount = web3.toWei(parseFloat($("#premiumAmount").val()));

    setStatus1("Initiating transaction... (please wait)");

    contractInstance.validate.sendTransaction({from: account, value: amount, gas: 200000}).then(
      txHash => {
        console.log(txHash);
        refreshVars();
    });
  });

  $("#exerciseBtn").click(function() {
    var amount = web3.toWei(parseFloat($("#callAmount").val()));

    setStatus2("Initiating transaction... (please wait)");

    contractInstance.exercise.sendTransaction({from: account, value: amount, gas: 200000}).then(
      txHash => {
        console.log(txHash);
        refreshVars();
    })
  })
}

window.addEventListener('load', function() {

  $("#tabs").tabs();
  setWeb3Provider(CallOption);

  start();
});
