// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Ownable
 * @dev This contract sets up an ownership system.
 * It allows for transferring ownership and restricting access to certain functions to the owner only.
 */
contract Ownable {
    address public  owner;

    event changedOwner(address indexed newOwner, address indexed oldOwner, string message);


    /**
     * @dev Sets the initial owner of the contract to the address deploying the contract.
     */
    constructor () payable {
        owner = payable (msg.sender);
    }

   /**
     * @dev Modifier to restrict function access to the contract owner only.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "You are not allowed");
        _;
    }

    /**
     * @dev Retrieve the current owner of the contract.
     * @return The address of the current owner.
     */
    function getOwner() internal  view returns (address) {
        return  owner;
    }

    /**
     * @dev Change the owner of the contract to a new address.
     * @param _newOwner The address of the new owner.
     * Emits a {changedOwner} event.
     */
    function changeOwner(address  payable _newOwner)  public onlyOwner {
        require(_newOwner != address(0), "Invalid address");

        emit changedOwner(_newOwner, owner, "This owner has been changed");
        owner = _newOwner;

    }
}
