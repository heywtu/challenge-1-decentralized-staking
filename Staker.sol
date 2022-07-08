// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  event Stake(address,uint256);

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);    
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  mapping ( address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  function stake() public payable {
    require(block.timestamp < deadline,"NO MORE");
    require(!executed,"ALREADY EXE");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender,msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  uint256 public deadline = block.timestamp + 30 seconds;

  bool public openForWithdraw;
  bool public executed;

  function execute() public {
    require(block.timestamp > deadline, "NOT YET");
    require(!executed,"ALREADY EXE");
    executed = true;

    if(address(this).balance >= threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }else{
      openForWithdraw = true;
    }
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public {
    require(openForWithdraw,"NOT OPEN FOR WITHDRAW");
    require(balances[msg.sender]>0,"NO BAL");
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool sent, ) = msg.sender.call{value:amount}("");
    require(sent,"Failed to send ether");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if(block.timestamp >= deadline){
      return 0;
    }else{
      return deadline-block.timestamp;
    }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable{
    stake();
  }

}