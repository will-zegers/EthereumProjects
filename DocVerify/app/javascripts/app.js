import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';
var SHA256 = require("crypto-js/sha256");
var ENC_HEX = require("crypto-js/enc-hex");


import docverify_artifacts from '../../build/contracts/DocVerify.json';

var DocVerify = contract(docverify_artifacts);
var web3;

window.App = {

  start: function() {

    setWeb3Provider(DocVerify);
    DocVerify.deployed().then(contractInstance => {
      this.contractInstance = contractInstance;
    }).then(() => {
      $("#cf_address").html(this.contractInstance.address);
      this.updateNumDocumentsHTML();
      web3.eth.getCoinbase((err, coinbase) => {
        this.coinbase = coinbase;
        this.account = coinbase;
        this.refreshBalance();
      });
    });
  },

  setStatus: function(message) {
    $("#status").html(message);
  },

  updateNumDocumentsHTML: function() {
    this.contractInstance.numDocuments.call().then(numDocuments => {
      $("#cf_documents").html(numDocuments.toNumber());
    });
  },

  refreshBalance: function() {
    web3.eth.getBalance(this.coinbase, 'latest', (err, balance) => {
      $("#cb_address").html(this.coinbase);
      $("#cb_balance").html(web3.fromWei(balance, "ether").toFixed(5));
    })
  },

  finished: function(result) {
    this.docHash = result.toString(ENC_HEX);
    $("#docHash").html(this.docHash);
    this.setStatus("Hash calculation done");
  },

  calculateHash: function() {
    this.setStatus("Calculating hash");
    var file = document.getElementById("fileUpload").files[0];
    var reader = new FileReader();
    reader.readAsBinaryString(file);
    reader.onload = e => {
      var data = e.target.result;
      var res = SHA256(data, this.progress, this.finished);
      this.finished(res);
    };
  },

  submitDocument: function() {
    this.setStatus("Submitting document... (please wait)");

    this.contractInstance.newDocument.sendTransaction(this.docHash, {from:this.account}).then(
      () => {
        this.updateNumDocumentsHTML();
        return this.contractInstance.documentExists.call(this.docHash);
    }).then(
      exists => {
        if (exists)
          this.setStatus("Document hash submitted");
        else
          this.setStatus("Error in submitting document hash");
        this.refreshBalance();
    })
  },

  verifyDocument: function() {
    this.setStatus("Verifying document... (please wait)");

    this.contractInstance.documentExists.call(this.docHash).then(
      exists => {
        if(exists)
          this.contractInstance.getDocument.call(this.docHash).then(
            result => {
              this.showDocumentInfo(result);
          });
        else
          this.setStatus("Document cannot be verified");
        this.refreshBalance();
    });
  },

  showDocumentInfo: function(result) {
    var res = "Document registered: " + this.getDateSring(result[0]) + "<br>Document Owner: " + result[1];
    this.setStatus(res);
  },

  getDateSring(date) {
    var theDate = new Date(date.toNumber() * 1000);
    return theDate.toGMTString();
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

  App.start();
});
