//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe{
    //safemathchainlink avoids overflows, overflows are intergers wrapping around the greatest value
    //for example uint8 has the greatest value 255, adding 1 to it will make the value 0 
    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    //now we keep track of who sent us the money by mapping address to amount
    address public owner;
    AggregatorV3Interface public priceFeed;
    address[] public funders;

    constructor(address _priceFeed) public{
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    } 
    function fund() public payable {
        
        
        //**********WE ARE USING EVEYTHING IN "GWEI TERMS" SO EVERYTHING HAS 18 ZEROS*******************
        
        
        //a payable function can be used to pay for things, when we make a transaction, we can attach a value to it and this value is the amount of crypto we will send with our function
        addressToAmountFunded[msg.sender] += msg.value;

        //with fund we send money to the smart contract (not another account)
        //ABI tells solidity or another programming language how to interact with a smart contract

        //  * * * ORACLES * * *      
        //Oracles or data sources do not interact directly with the smart contract so 
        //we need an oracle blockchain to act as an intermediary 
        //having multiple oracles results in nodes reaching no consensus and having one oracle makes the network centralized
        //therefore we need chainlink, chainlink is a modular decentralized oracle infrastructure that allows us
        //to get data in a decentralized manner, its customizable, one to any number of nodes as we please
        uint256 minimumUSD = 5 * 10 ** 18;

        require(getConversionRate(msg.value) > minimumUSD, "Error: You need to spend more eth");

        funders.push(msg.sender);
    }

  

    function getVersion() public view returns(uint256){

        //solidity doesnt understand how to interact with a contract natively, we have to tell solidity how to interact with another smart contract using an interface 
        //interfaces dont have full function implementations, just function name and return type
        //interfaces compile down to ABI
        //this line says we have all the functions of AggregatorV3Interface located in the specified address
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256) {
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10**10);

    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount)/(10**18);
        return ethAmountInUSD; 
        //price of 1 gwei = 000000308995901234
    }

    function getEntranceFee() public view returns (uint256) {
        //min USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price); 
    }

    modifier onlyOwner{
         require(msg.sender == owner);
         _;
    }

    function withdraw() payable onlyOwner public{
        //only the owner should be able to withdraw the amount
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex<funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            //after the owner withdraws, all the addresses that funded the contract have their addresstofunded mapping turned to 0
        }
        funders = new address[](0);
        //empties the entire funders array
    }
}