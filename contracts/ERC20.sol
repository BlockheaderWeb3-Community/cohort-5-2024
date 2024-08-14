// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

/**
 * @title ERC20
 * @dev Implementation of the ERC20 token standard
 */
contract ERC20 is IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     * 
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Emitted when ownership of the contract is transferred from `old` to `new`.
     */
    event Owned(address indexed old, address indexed new);

    /**
     * @notice Total supply of tokens.
     */
    uint256 public totalSupply;

    /**
     * @notice Mapping of account balances.
     */
    mapping(address => uint256) public balanceOf;

    /**
     * @notice Mapping of allowances for each spender.
     */
    mapping(address => mapping(address => uint256)) public allowance;

    /**
     * @notice The name of the token.
     */
    string public name;

    /**
     * @notice The symbol of the token.
     */
    string public symbol;

    /**
     * @notice The number of decimals the token uses.
     */
    uint8 public decimals;

    /**
     * @dev The address of the contract owner.
     */
    address private owner;

    /**
     * @dev Error for insufficient balance in operations.
     */
    error InsufficientBalance();

    /**
     * @dev Error for invalid recipient addresses (e.g., zero address).
     */
    error InvalidRecipient();

    /**
     * @dev Error for arithmetic overflow during operations.
     */
    error Overflow();

    /**
     * @dev Error for arithmetic underflow during operations.
     */
    error Underflow();

    /**
     * @notice Initializes the contract with a `name`, `symbol`, and `decimals`.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _decimals The number of decimals the token uses.
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    /**
     * @dev Modifier to allow only the owner to execute certain functions.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    /**
     * @notice Transfers `amount` tokens to the `recipient`.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return True if the operation was successful.
     * @dev Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        unchecked {
            balanceOf[msg.sender] -= amount;
            balanceOf[recipient] += amount;
        }

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @notice Approves `spender` to spend `amount` on behalf of the caller.
     * @param spender The address of the spender.
     * @param amount The amount of tokens to approve.
     * @return True if the operation was successful.
     * @dev Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        if (spender == address(0)) {
            revert InvalidRecipient();
        }
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfers `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param amount The amount of tokens to transfer.
     * @return True if the operation was successful.
     * @dev Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(msg.sender != recipient, "cannot transfer to self");
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        uint b = allowance[sender][msg.sender];
        uint c = b - amount;
        if (c > b) {
            revert InsufficientBalance();
        }

        unchecked {
            allowance[sender][msg.sender] -= amount;
            balanceOf[sender] -= amount;
            balanceOf[recipient] += amount;
        }

        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev Internal function to mint `amount` tokens to `to`.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     * @dev Emits a {Transfer} event from the zero address.
     */
    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) {
            revert InvalidRecipient();
        }

        if (totalSupply + amount < totalSupply) {
            revert Overflow();
        }

        unchecked {
            balanceOf[to] += amount;
            totalSupply += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev Internal function to burn `amount` tokens from `from`.
     * @param from The address from which tokens will be burned.
     * @param amount The amount of tokens to burn.
     * @dev Emits a {Transfer} event to the zero address.
     */
    function _burn(address from, uint256 amount) internal {
        if (totalSupply - amount > totalSupply) {
            revert Underflow();
        }

        unchecked {
            balanceOf[from] -= amount;
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

    /**
     * @notice Mints `amount` tokens to `to`. Can only be called by the owner.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice Burns `amount` tokens from `from`. Can only be called by the owner.
     * @param from The address from which tokens will be burned.
     * @param amount The amount of tokens to burn.
     */
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    /**
     * @notice Transfers ownership of the contract to `newOwner`.
     * @param newOwner The address of the new owner.
     * @return True if the operation was successful.
     * @dev Emits an {Owned} event.
     */
    function changeOwner(address newOwner) public onlyOwner returns (bool) {
        address oldOwner = owner;
        owner = newOwner;
        emit Owned(oldOwner, newOwner);
        return true;
    }
}