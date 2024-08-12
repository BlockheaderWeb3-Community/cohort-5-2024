// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance; // 1stAddr - owner, 2ndAddr - spender
    string public name;
    string public symbol;
    uint8 public decimals;

    address public owner;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not authorized");
        _;
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        require(recipient != address(0), "Recipient cannot be address zero");
        require(balanceOf[msg.sender] > amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    mapping(address => bool) private approvalMap;

    function approve(address spender, uint256 amount) external onlyOwner returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        allowance[msg.sender][spender] = amount;
        approvalMap[spender] = true;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        require(recipient != address(0), "Recipient cannot be address zero");
        require(approvalMap[msg.sender] == true, "You have not been approved by sender");
        require(allowance[sender][msg.sender] >= amount, "Allowance Exceeded");
        require(msg.sender != recipient, "You cannot be the recipoent");

        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal onlyOwner {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Excess Burn Amount");
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
