// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Counter {
    uint public count;
   
    event CountIncreased(uint amount, uint when);
    event CountDecreased(uint amount, uint when);

  
    // function to increase count by one
    function increaseByOne() public {
        count += 1;
        emit CountIncreased(count, block.timestamp);
    }

    // function to decrease count by one
    function decreaseByOne() public { 
        require(count > 0, "cannot decrease below 0");
        count -= 1;
        emit CountDecreased(count, block.timestamp);
    }
}
