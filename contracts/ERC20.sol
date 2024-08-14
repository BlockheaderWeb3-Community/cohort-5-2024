// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract ERC20 is IERC20, Ownable, ReentrancyGuard {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );

    // Proper Events for burn and mint functions
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    uint256 public totalSupply;
    string public name;
    string public symbol;

    // decimal state was missing
    uint8 public decimals;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address recipient, uint256 amount)
        external
        nonReentrant // Added Reentrancy Guard modifier
        returns (bool)
    {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance"); // Check if there is enough balance to go through
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function approve(address spender, uint256 amount) external onlyOwner returns (bool) { // Only owner can approve spender
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        nonReentrant
        returns (bool)
    {
        require(balanceOf[sender] >= amount, "Insufficient balance"); // Check if sender has enough balance to go through
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded"); // Check if address has enough allocation
        
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal onlyOwner { // Only owner can mint tokens
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Mint(to, amount); // proper log mint action
    }

    function _burn(address from, uint256 amount) internal onlyOwner { // Only owner can burn tokens
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Burn(from, amount); // proper log burn action
    }

    function mint(address to, uint256 amount) external  {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}