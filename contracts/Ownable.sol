// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Ownable {

    address private owner;
    uint256 public fee;

    event ChangeOwner(address indexed oldOwner, address indexed  newOwner);

    constructor() payable {
        owner = payable (msg.sender);
        fee = 1 ether;
    }


    modifier onlyOwner {
        require(owner == msg.sender, "Caller not owner");
        _;
    }


    function getOwner() public  view returns (address){
        return owner;
    }


    function changeOwner(address _newOwner) internal onlyOwner {
        require(_newOwner != address(0), "Owner can not be address zero");
        
        emit ChangeOwner(owner, _newOwner);
        owner = _newOwner;
    }

      // Function to withdraw all Ether from this contract.
    function withdraw() public payable onlyOwner {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;
        require(amount > 0, "No student has registered yet.");

        // send all Ether to owner
        (bool success,) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

   

}