// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ReentrancyGuard {
     uint256 private constant UNLOCKED = 1;
     uint256 private constant LOCKED = 2;
     uint256 private _status;

    constructor() {
        _status = UNLOCKED;
    }

    modifier nonReentrant() {
        require(_status != LOCKED, "Kindly wait a bit!");
        _status = LOCKED;
        _;
        _status = UNLOCKED;
    }

}