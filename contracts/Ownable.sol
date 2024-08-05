// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Ownable {

    address private owner;

    event ChangeOwner(address indexed oldOwner, address indexed  newOwner);

    constructor(){
        owner = msg.sender;
    }


    modifier  onlyOwner {
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
}