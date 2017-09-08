import { default as Web3 } from 'web3';
import { default as contract } from 'truffle-contract';

import revenueShare_artifacts from '../../build/contracts/RevenueShare.json';

var RevenueShare = contract(revenueShare_artifacts);

var contractAddress;

window.App = {

  init: function() {
    RevenueShare.setProvider(web3.currentProvider);
    RevenueShare.deployed().then(instance => {
      this.instance = instance;
    }).then(() => {
      App.updateAccountsTable();
    })
  },

  updateAccountsTable: function() {
    App.updateContractRow();
    App.updateCoinbaseRow();
    App.updateShareholderRow(0, 'a');
    App.updateShareholderRow(1, 'b');
  },

  updateContractRow: function() {
    $("#c_address").html(this.instance.address);
    App.getAccountBalanceInEther("#c_balance", this.instance.address);
  },

  updateCoinbaseRow: function() {
    this.instance.creator.call().then(account => {
      $("#cb_address").html(account);
      App.getAccountBalanceInEther("#cb_balance", account);
    });
  },

  updateShareholderRow : function(shareholderIndex, htmlIdTag) {
    this.instance.shareholders.call(shareholderIndex).then(account => {
      $("#"+htmlIdTag+"_address").html(account);
      App.getAccountBalanceInEther("#"+htmlIdTag+"_balance", account);
    });
  },

  getAccountBalanceInEther: function(htmlIdTag, account) {
    web3.eth.getBalance(account, 'latest', function(err, balance) {
      $(htmlIdTag).html(web3.fromWei(balance, 'ether').toFixed(5));
    });
  },

  setStatus: function(message) {
   $("#status").html(message);
  },

  send: function() {

    App.setStatus("Initiating transaction... (please wait)");

    var amount = web3.toWei(parseFloat($("#amount").val()), "ether");

    web3.eth.sendTransaction({from: web3.eth.coinbase, to: this.instance.address, value: amount, gas: 2000000},
      function(err, txHash) {
        if (err)
          App.transactionError();
        else
          web3.eth.getTransactionReceipt(txHash, function(err, receipt) {
            if (err)
              App.receiptError();
            else
              App.transactionSuccessful(receipt);
          });
      });
  },

  transactionError: function() {
    App.setStatus("Transaction failed:\n" + err)
    console.log(err);  
  },

  receiptError: function() {
    App.setStatus("Transaction successful, but could not get receipt.");
    console.log(err);    
  },

  transactionSuccessful: function(receipt) {
    App.setStatus("Transaction complete!");
    console.log(receipt);
    App.updateAccountsTable();
  }
}

window.addEventListener('load', function() {

  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask");
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  App.init();
});