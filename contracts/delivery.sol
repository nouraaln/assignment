// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
 

import "./auction2.sol";
 
contract PhysicalDelivery is SimpleAuction {

    address public retailStore;
    uint secuirtyDeposit = 1 ether;
    mapping (address => bool) approvedBuyer;
    mapping (address => bool) courierPaid;
    mapping (uint256 => address) itemToBuyer;
    mapping(address => Courier_Type) public Courier;
    event newDeliveryRequest(address buyerEA, uint256 tokenID);
    event deliveryTaken(address courierEA);
    event startDelivery(address courierEA, uint time);
    event successfulDelivery(address courierEA, address buyerEA, uint256 itemSN);
    event failedDelivery(address courierEA, address buyerEA, uint256 itemSN);

    struct Courier_Type{
        uint256 itemSN;
        address payable buyerEA;
        bool courierPaid;
        bool buyerPaid;
        bool busy;
    }
    constructor(){
        retailStore = msg.sender;
    }

    modifier onlyRetail(){
        require(msg.sender == retailStore, "NOT_RETAIL_STORE");
        _;
    }

    function approveBuyer(address _buyerEA, uint256 _itemSN) external onlyRetail{
        approvedBuyer[_buyerEA] = true;
        itemToBuyer[_itemSN] = _buyerEA;
        emit newDeliveryRequest( _buyerEA, _itemSN);
    }

    function courierEstablishDelivery(address payable _buyerEA, uint256 _itemSN) public payable{
        require(msg.value == secuirtyDeposit, "NOT_ENOUGH_ETHER");
        require(itemToBuyer[_itemSN] == _buyerEA, "ERROR_BUYER_ITEM");
        require(!Courier[msg.sender].busy, "COURIER_HAS_REQUEST");
        Courier[msg.sender].itemSN = _itemSN;
        Courier[msg.sender].buyerEA = _buyerEA;
        Courier[msg.sender].courierPaid = true;
        emit deliveryTaken(msg.sender);
    }

    function buyerDeposit(address courierEA) public payable{
        require(msg.sender == Courier[courierEA].buyerEA, "NOT_CORRECT_BUYER");
        require(msg.value == secuirtyDeposit, "NOT_ENOUGH_ETHER");
        require(Courier[courierEA].courierPaid, "NO_DEPOSIT");
        Courier[courierEA].buyerPaid = true;
        Courier[courierEA].busy = true;
        emit startDelivery(courierEA,   block.timestamp);
    }

    function buyerApproval(address payable courierEA, bool approved) public payable{
        require(msg.sender == Courier[courierEA].buyerEA, "NOT_CORRECT_BUYER");
        if(approved){
            payable(msg.sender).transfer(secuirtyDeposit);
            courierEA.transfer(secuirtyDeposit);
            emit successfulDelivery(courierEA, msg.sender, Courier[courierEA].itemSN);
            super._transferBid(msg.sender);
            //delete(Courier[courierEA]);
            //Courier[courierEA].itemSN = 0;
            //Courier[courierEA].buyerEA = 0;
            //Courier[courierEA].courierPaid = false;
            //Courier[courierEA].buyerPaid = false;
            //Courier[courierEA].busy = false;
            
        }
        else{
            emit failedDelivery(courierEA, msg.sender, Courier[courierEA].itemSN);
        }
    }

    function returnDeposit(address payable accountEA) external onlyRetail{
        accountEA.transfer(secuirtyDeposit);
    }

    function changeDeposit(uint _fee) external onlyRetail{
        secuirtyDeposit = _fee;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }


}