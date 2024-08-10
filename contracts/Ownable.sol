// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

/**
    @title Ownable Contract
    @author Henry Peters.
    @notice BlockHeader BootCamp, Cohort-5.
    @notice This contract provides basic authorization control functions, simplifying the implementation of user permissions.
    @dev This contract sets an owner upon deployment and provides functions to check and change the ownership.
*/
contract Ownable {
    /// @notice The address of the current owner of the contract.
    address payable private owner;

    /**
        @notice Emitted when ownership of the contract is transferred.
        @param oldOwner The address of the previous owner.
        @param newOwner The address of the new owner.
    */
    event ChangeOwner(address indexed oldOwner, address indexed newOwner);

    /**
        @notice The constructor function sets the owner of the contract to the account that deployed the contract.
        @dev The msg.sender is assigned as the owner when the contract is deployed.
    */
    constructor() {
        owner = payable(msg.sender);
    }

    /**
        @notice Function modifier to make a function callable only by the owner.
        @dev Reverts if the caller is not the owner.
    */
    modifier onlyOwner() {
        require(owner == msg.sender, "Caller not owner");
        _;
    }

    /**
        @notice Returns the address of the current owner.
        @dev This function is marked as view, indicating it doesn't modify the contract's state.
        @return The address of the current owner.
    */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
        @notice Transfers ownership of the contract to a new owner.
        @dev This function can only be called by the current owner.
        @param _newOwner The address to which ownership is being transferred. It must be a valid address.
    */
    function changeOwner(address payable _newOwner) internal onlyOwner {
        require(_newOwner != address(0), "Owner can not be address zero");

        emit ChangeOwner(owner, _newOwner);
        owner = _newOwner;
    }
}