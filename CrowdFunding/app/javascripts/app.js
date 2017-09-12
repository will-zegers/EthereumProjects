import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';

import crowdfunding_artifacts from '../../build/contracts/CrowdFunding.json';

var CrowdFunding = contract(crowdfunding_artifacts);
var web3;

window.App = {

  start: function() {

    this.setWeb3Provider();

    CrowdFunding.setProvider(web3.currentProvider);
    CrowdFunding.deployed().then(contractInstance => {

      this.contractInstance = contractInstance;
      $("#cf_address").html(contractInstance.address);
      $("#qr_code").html("<img src=\"https://chart.googleapis.com/chart?cht=qr&chs=350&chl="+contractInstance.address+"\" height=\"350\"/>");

      contractInstance.owner.call().then(coinbase => {
        this.account = coinbase;
        $("#cb_address").html(coinbase);      
        web3.eth.getBalance(coinbase, (err, balance) => {
          $("#cb_balance").html(web3.fromWei(balance, "ether").toFixed(5));
        });
      });
 mein
      web3.eth.getBalance(contractInstance.address, 'latest', (err, balance) => {
        $("#cf_balance").html(web3.fromWei(balance, "ether").toFixed(5));
      });

      contractInstance.numBackers.call().then(numBackers => {
        $("#cf_backers").html(numBackers.toNumber());
      });

      contractInstance.goalInWei.call().then(goalInWei => {
        $("#cf_goal").html(web3.fromWei(goalInWei.toNumber()));
      });

      contractInstance.campaignStatus.call().then(status => {
        $("#cf_status").html(status);
      });

      contractInstance.deadlineInSeconds.call().then(deadlineInSeconds => {
        var date = new Date(1000*deadlineInSeconds.toNumber());
        var dateString = "";
        dateString += date.getHours() + ':' + this.padIfLessThanZero(date.getMinutes()) + ' ';
        dateString += (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear();

        $("#cf_days").html(dateString);
      });
    });
  },

  setWeb3Provider: function() {
    if (typeof web3 !== 'undefined')
      web3 = new Web3(web3.currentProvider);
    else
      web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  },

  padIfLessThanZero: function(minutes) {
    return (minutes < 10) ? '0' + minutes : minutes;
  },

  setStatus : function(message) {
    $("#status").html(message);
  },

  checkGoalReached: function() {

    this.contractInstance.deadlineHasPassed.call().then(deadlineHasPassed => {
      if (deadlineHasPassed) {
        this.contractInstance.closeOutCampaign.sendTransaction({from: this.account, gas: 200000}).then(() => {
          return this.contractInstance.goalInWei.call();
        }).then(goalInWei => {
          $("#cf_goal").html(web3.fromWei(goalInWei, "ether").toFixed(5));
          return this.contractInstance.campaignStatus.call();
        }).then(campaignStatus => {
          console.log(campaignStatus);
          $("#cf_status").html(campaignStatus);  
        }).catch(err => {
          console.log("There was an error sending funds");
        });
      } else {
        console.log("Could not close out. Either the campaign has not ended or the contract has already closed out.")
      }
    });
  },

  refreshBalances: function() {
    web3.eth.getCoinbase((err, coinbase) => {
      web3.eth.getBalance(coinbase, (err, balance) => {
        $("#cb_balance").html(web3.fromWei(balance, "ether").toFixed(5));
      });
    })

    this.contractInstance.numBackers.call().then(numBackers => {
      $("#cf_backers").html(numBackers.toNumber())
      return this.contractInstance.amountRaised.call();
    }).then(amountRaised => {
      $("#cf_balance").html(web3.fromWei(amountRaised, "ether").toFixed(5));
    });
  },

  contribute: function() {

    var amount = web3.toWei(parseFloat($("#amount").val()), "ether");
    this.setStatus("Initiating transaction... (please wait)");
    
    this.contractInstance.fund.sendTransaction({from: this.account, value: amount, gas:2000000}).then(txHash => {
      web3.eth.getTransactionReceipt(txHash, receipt => {
        this.setStatus("Transaction complete!");
        this.refreshBalances();
      });
    }).catch(err => {
      console.log(err);
      this.setStatus("Error completing transaction.");
    });
  }
}

window.addEventListener('load', function() {

  App.start();
});
