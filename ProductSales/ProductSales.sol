pragma solidity ^0.4.14;

contract ProductSales {
  struct Product {
    uint ID;
    string name;
    uint inventory;
    uint price;
  }

  struct Buyer {
    string name;
    string email;
    string mailingAddress;
    uint totalOrders;
    bool isActive;
  }

  struct Order {
    uint orderID;
    uint productID;
    uint quantity;
    address buyer;
  }

  address public owner;
  mapping (address => Buyer) public buyers;
  mapping (uint => Product) public products;
  mapping (uint => Order) public orders;

  uint public numProducts;
  uint public numBuyers;
  uint public numOrders;
  address public lastRegisteredBuyer;

  event NewProduct(uint _ID, string _name, uint _inventory, uint _price);
  event NewBuyer(string _name, string _email, string _mailingAddress);
  event NewOrder(uint _OrderID, uint _ID, uint _quantity, address _from);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function ProductSales() {
    owner = msg.sender;
    numBuyers = 0;
    numProducts = 0;
  }

  function addProduct(uint _ID, string _name, uint _inventory,
                      uint _price) onlyOwner {
    Product storage p = products[_ID];
    p.ID = _ID;
    p.name = _name;
    p.inventory = _inventory;
    p.price = _price;
    ++numProducts;
    
    NewProduct(_ID, _name, _inventory, _price);
  }

  function updateProduct(uint _ID, string _name, uint _inventory,
                         uint _price) onlyOwner {
    products[_ID].name = _name;
    products[_ID].inventory = _inventory;
    products[_ID].price = _price;
  }

  function registerBuyer(string _name, string _email, string _mailingAddress) {
    Buyer storage b = buyers[msg.sender];
    lastRegisteredBuyer = msg.sender;
    b.name = _name;
    b.email = _email;
    b.mailingAddress = _mailingAddress;
    b.totalOrders = 0;
    b.isActive = true;
    ++numBuyers;
    
    NewBuyer(_name, _email, _mailingAddress);
  }

  function buyProdct(uint _ID, uint _quantity) payable 
    returns (uint newOrderID) {

    uint orderAmount = products[_ID].price * _quantity;

    require (products[_ID].inventory < _quantity);
    require(msg.value > orderAmount);
    require(buyers[msg.sender].isActive == true);

    buyers[msg.sender].totalOrders++;

    newOrderID = uint(msg.sender) + block.timestamp;

    Order storage o = orders[newOrderID];
    o.orderID = newOrderID;
    o.productID = _ID;
    o.quantity = _quantity;
    o.buyer = msg.sender;

    numOrders++;

    products[_ID].inventory++;

    if (msg.value > orderAmount) {
      uint refundAmount = msg.value - orderAmount;
      assert(msg.sender.send(refundAmount));
    }

    NewOrder(newOrderID, _ID, _quantity, msg.sender);
  }

  function withdrawFund() onlyOwner {
    assert(owner.send(this.balance));
  }

  function kill() onlyOwner {
    suicide(owner);
  }
}
