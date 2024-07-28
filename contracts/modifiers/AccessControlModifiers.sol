// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Access Control Modifiers Contract
/// @notice This contract contains access control modifiers for ownership and authorization
contract AccessControlModifiers {
    address private owner;

    /// @notice Constructor sets the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Modifier to allow only the owner to execute the function
    /// @dev Reverts if the caller is not the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    /// @notice Modifier to allow only authorized addresses to execute the function
    /// @dev Reverts if the address is not authorized
    /// @param _address The address to check for authorization
    modifier onlyAuthorized(address _address) {
        require(isAuthorized(_address), "Not authorized");
        _;
    }

    /// @notice Checks if an address is authorized
    /// @dev This is a placeholder function for custom authorization logic
    /// @param _address The address to check for authorization
    /// @return bool True if the address is authorized, false otherwise
    function isAuthorized(address _address) internal view returns (bool) {
        //@dev Custom authorization logic
        return _address == owner; 
    }
}