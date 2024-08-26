// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./StudentStruct.sol";
import "./modifiers/Ownable.sol";
import "./modifiers/InputValidations.sol";

/**
 * @title student Payment
 * @dev This contract manages student registration payment, authorization, and details.
 * It handles student registration payment.
 */
contract Payment is Ownable, InputValidation {

    event PaymentStatus(bool indexed hasPaid, string message);

    // Mapping of student address to payment receipt amount
    mapping  (address => uint256) internal PaymentDetails;
   

   // Make payment
    function payFees() public payable {
        uint256 amount = msg.value;
        require(amount == 1 ether, "1 eth is required");
         PaymentDetails[msg.sender] = amount;
        emit PaymentStatus(true, "Payment successful!!");
    }

     /**
        @notice Withdraws the contract's balance to the owner's address.
        @return withdrawal indicating the withdrawal was successful.
    */
    function withdrawEarnings() public onlyOwner returns(bool)  {
        // get the amount of Ether stored in this contract
        uint256 amount = address(this).balance;
        require(amount > 0, "Empty Balance");
        // send all Ether to owner
        (bool withdrawal,) = owner.call{value: amount}("");
        require(withdrawal, "Failed to send Ether");
        return withdrawal;
    }

    // Function to transfer Ether from this contract to address from input
    function transfer(address payable _to, uint256 _amount) public onlyOwner {
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}