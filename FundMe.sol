//To get funds from users
// withdraw funds
//Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error notOwner();

contract FundMe {
    using PriceConverter for uint256;

    //allow users to send USD
    //have a minimum $ sent
    uint256 public minimumUsd = 5e18; //5*1e18. Since 1e18 wei is 1 eth
    //we can also use constant keywords because we are not upadating the value;
    uint256 public constant MINUMUM_USD = 5e18;

    address[] public funders;  //to get the details of funders

    mapping(address => uint256 amountFunded) public addressToAmountFunded; //to know how much amout has each funder funded

    address public owner;
    //can be defined as 
    // address public immutable i_owner;
    constructor(){
        owner = msg.sender;
    }
    // uint256 public gasValue = 1;
    function fund() public payable {
        // gasValue = gasValue +2;
        // require(msg.value > 1e18, "didn't send enough ETH"); //number of wei sent with the message, 1e18 is 1ETH

        require((msg.value.getConversionRate()) >= minimumUsd, "didn't send enough ETH");

        // msg.value.getConversionRate();
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        require(msg.sender== owner,"Must be Owner");  //only the owner can withdraw funds
        for(uint256 funderIndex =0; funderIndex< funders.length; funderIndex++){
           address funder =  funders[funderIndex];
           addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); //reset funders array 

        //transfer funds
        payable(msg.sender).transfer(address(this).balance);

        //send
       bool sendSuccess =  payable(msg.sender).send(address(this).balance);
       require(sendSuccess, "Send failed");

        //call
        (bool callSuccess, /*bytes memory dataReturned*/) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call Failed");
    }

    //modifiers basically acts as middlewares in the contracts
    modifier onlyOwner(){
        // require(msg.sender== owner,"Must be Owner");
        if(msg.sender != owner){revert notOwner();}
        _;
    }
}
