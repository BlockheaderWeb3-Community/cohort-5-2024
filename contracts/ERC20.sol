// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0 ;

import "./IERC20.sol";
import "./Ownable.sol";

contract ERC20 is IERC20, Ownable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);


    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address recipient, uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        require(recipient != address(0), "A Transfer to Address Zero!");
        require(amount <= balanceOf[msg.sender]);
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    function approve(address spender, uint256 amount) external onlyOwner returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        require(amount <= allowance[sender][msg.sender], "Transfer amount exceeds allowance");
        require(amount <= balanceOf[msg.sender]);
        require(msg.sender != recipient, "cannot transfer to self");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address to, uint256 amount) onlyOwner internal {
        require(to != address(0), "You can't mint to Address Zero!");
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Mint(to, amount);
    }

    function _burn(address from, uint256 amount) onlyOwner internal {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Burn(from, amount);
        
    }

    function mint(address to, uint256 amount) onlyOwner external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) onlyOwner external {
        _burn(from, amount);
    }
}
