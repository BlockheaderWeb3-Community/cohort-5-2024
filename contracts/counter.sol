// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


/** 
 * @title Counter
 * @author Iwuese
 * @dev Implements a simpleCounter 
 */
contract SimpleCounter {

    uint8 private count = 0; // local variable 



    /**
    *@dev get count from 'count'.
    *@return value of count
    *@notice value returned fron count = 0
    */
    function getCount() public view returns (uint8) {
        return count; 
    }



    /**
    *@dev sets the value of count. 
    *@notice the current value of count changes to value of _amount
    */

     function setCount(uint8 _amount)  public {
        count = _amount; 
    }


    /**
    *@dev computes add count to increase the value of 'count'
    *@notice the value of count increasing by 1.
    */
    function increaseCount() public {
        count ++;
    }


    /**
    *@dev computes subtractCount to decrease the value of 'count'
    *@notice the value of count decreasing by 1.
    */
     function decreaseCount () public {
    count--;
    }

    /**
    *@dev 'decrement' to check that count is above or equal to zero.  
    *@notice the value of count is not decreasing below zero.
    */

    function decrement ( uint8) public {
         if (count > 0) {
            count -= 1;
        } 
    }


}