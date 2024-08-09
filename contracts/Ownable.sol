// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Ownable {

    address private owner;

    event ChangeOwner(address indexed oldOwner, address indexed  newOwner);

    constructor() payable {
        owner = payable (msg.sender);
    }

     modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner or admin");
        _;
    }

    modifier nameIsNotEmpty(string memory _name) {
        require(bytes(_name).length != 0, "Please input a name");
        _;
    }

    modifier isNotAddressZero() {
        require(msg.sender != address(0), "Invalid Address");
        _;
    }

    modifier upToAge(uint256 _age) {
        require(_age >= 18, "You must be above 18 to proceed");
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