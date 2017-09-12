import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';

import eventregistration_artifacts from '../../build/contracts/EventRegistration.json';

var EventRegistration = contract(eventregistration_artifacts);
var contractInstance;
var account;
var web3;

window.App = {

  start: function() {

    this.setWeb3Provider(EventRegistration);

    EventRegistration.deployed().then(instance => {
      contractInstance = instance;
    }).then(() => {
      this.updateContractAddress();
      this.updateRegistrantsHTML();
      this.updateQuotaHTML();
      this.updatePriceHTML();
    });

    web3.eth.getAccounts((err, accounts) => {
      account = accounts[0];
    });

    web3.eth.getCoinbase((err, coinbase) => {
      this.coinbase = coinbase;
      this.refreshCoinbaseBalance();
    });
  },

  setWeb3Provider: function(contract) {
    if (typeof web3 !== 'undefined')
      web3 = new Web3(web3.currentProvider);
    else
      web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    contract.setProvider(web3.currentProvider);
  },

  updateContractAddress: function() {
    $("#cf_address").html(contractInstance.address);
  },

  updateRegistrantsHTML: function() {
    contractInstance.numRegistrants.call().then(numRegistrants => {
      $("#cf_registrants").html(numRegistrants.toNumber());
    });
  },

  updateQuotaHTML: function() {
    contractInstance.quota.call().then(quota => {
      $("#cf_quota").html(quota.toNumber());
    });
  },

  updatePriceHTML: function() {
    contractInstance.pricePerTicket.call().then(pricePerTicket => {
      this.pricePerTicket = web3.fromWei(pricePerTicket, "ether").toNumber();
      $("#cf_price").html(this.pricePerTicket);
    }); 
  },

  setStatus: function(message) {
    $("#status").html(message);
  },

  showTotal: function() {
    var numTickets = $("#numTickets").val();
    var ticketsTotal = numTickets * this.pricePerTicket;
    $("#ticketsTotal").html(ticketsTotal);
  },

  refreshCoinbaseBalance: function() {
    web3.eth.getBalance(this.coinbase, 'latest', (err, balance) => {
      $("#cb_address").html(this.coinbase);
      $("#cb_balance").html(web3.fromWei(balance, "ether").toFixed(5));
    });
  },

  buyTickets: function() {
    var numTicketsToBuy = parseFloat($("#numTickets").val());
    var ticketAmountWei = web3.toWei(numTicketsToBuy * this.pricePerTicket, "ether");
    var email = $("#email").val();

    var amountAlreadyPaid;

    this.setStatus("Initiating transaction... (please wait)");

    contractInstance.getRegistrantAmountPaid.call(account).then(amountPaid => {
      amountAlreadyPaid = amountPaid.toNumber();
      return contractInstance.buyTickets(email, numTicketsToBuy, {from: account, value: ticketAmountWei, gas:2000000});
    }).then((res) => {
      return contractInstance.getRegistrantAmountPaid.call(account);
    }).then(amountPaid => {
      this.checkPurchaseSuccessful(amountPaid, amountAlreadyPaid, ticketAmountWei);
      this.refreshCoinbaseBalance();
      this.updateRegistrantsHTML();
    })
  },

  checkPurchaseSuccessful: function(amountPaid, amountAlreadyPaid, ticketAmountWei) {
    var amountPaidNow = amountPaid.toNumber() - amountAlreadyPaid;
    if (amountPaidNow == ticketAmountWei)
      this.setStatus("Purchase successful");
    else
      this.setStatus("Purchase failed");
  },

  cancelTickets: function() {
    this.setStatus("Initiating transaction... (please wait)");
    contractInstance.getRegistrantAmountPaid.call(account).then(amountPaid => {
      if (amountPaid == 0)
        this.setStatus("Buyer is not registered - no refund!");
      else
        contractInstance.refundTickets.sendTransaction(account, {from:account}).then(() => {
          return contractInstance.numRegistrants.call();
        }).then(numRegistrants => {
          $("#cf_registrants").html(numRegistrants.toNumber());
          return contractInstance.getRegistrantAmountPaid.call(account);
        }).then(amountPaid => {
          if (amountPaid.toNumber() == 0)
            this.setStatus("Refund successful");
          else
            this.setStatus("Refund failed");
          this.refreshCoinbaseBalance();
        })
    });
  }
}

window.addEventListener('load', function() {

  App.start();
});
