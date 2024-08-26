// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Ownable {

    address internal owner;
    event replaceOwner(address indexed newOwner, address indexed oldOwner, string message);
  

    /**
     * @dev Set the owner of the contract to the address deploying the contract.
     */
    constructor(){
        owner = payable (msg.sender);
    }


    /**
     * @dev restrict access to the contract owner only.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Unauthorized");
        _;
    }
    

    /**
     * @dev Retrieve the current owner of the contract.
     * @return The address of the current owner.
     */

    function getOwner() public  view returns (address){
        return owner;
    }



    /**
     * @dev Change the owner of the contract to a new address.
     * @param _newOwner The address of the new owner.
     * Emits a {changedOwner} event.
     */
    function changedOwner(address _newOwner) internal onlyOwner {
        require(_newOwner != address(0), "Owner can not be address zero");
        
        emit replaceOwner(_newOwner, owner, "This owner has been changed");
        owner = _newOwner;
    }
}