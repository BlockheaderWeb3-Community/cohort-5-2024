

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";

contract ERC20ContractTest is Test {
    ERC20 public erc20Contract;
    address ownerAddress = address(0x0101);
    address randomAddress = address(0x3892);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Owned(address indexed old, address indexed newAddress);


    error InvalidRecipient();

    function setUp() public {
        vm.prank(ownerAddress);
        erc20Contract = new ERC20("My Token", "MTK", 0);
    }

    function test_ContractWasDeployedSuccessfully() public view {
        assertEq(erc20Contract.name(), "My Token");
        assertEq(erc20Contract.symbol(), "MTK");
        assertEq(erc20Contract.decimals(), 0);
    }

    function test_OwnerisSetCorrectly() public view {
        assertEq(erc20Contract.owner(), ownerAddress, "owner address not set correctly");
    }

    function test_MintWillRevertWhenMintFromUnauthorizedAddress() public {
        address scammer = address(0x5555);
        vm.startPrank(scammer);
        vm.expectRevert("Unauthorized");
        erc20Contract.mint(scammer, 1000);
        vm.stopPrank();
    }

    function test_MintWillRevertWhenMintToZeroAddress() public {
        // Set msg.sender to `ownerAddress`
        vm.prank(ownerAddress);
        // Expect function call to revert
        vm.expectRevert(InvalidRecipient.selector);
        // Mint 1000 tokens to zero address
        erc20Contract.mint(address(0), 1000);
    }

    function test_MintWasSuccessful() public {
        uint256 totalSupplyBeforeMint = erc20Contract.totalSupply();
        uint256 mintAmount = 1000;
        // Check balance before mint
        assertEq(erc20Contract.balanceOf(randomAddress), 0, "expected random address balance to be 0");
        // Set msg.sender to `ownerAddress`
        vm.prank(ownerAddress);
        // Mint 1000 tokens to random address
        erc20Contract.mint(randomAddress, mintAmount);
        uint256 totalSupplyAfterMint = erc20Contract.totalSupply();
        // Verify mint was successful
        assertEq(erc20Contract.balanceOf(randomAddress), mintAmount, "incorrect mint amount");
        assertEq(totalSupplyBeforeMint + mintAmount, totalSupplyAfterMint);
    }

    function test_transfer() public {
        address recipient = address(0x2938);
        assertEq(erc20Contract.balanceOf(recipient), 0, "Amount supposed to be 0");
        assertEq(erc20Contract.balanceOf(ownerAddress), 0, "Amount supposed to be 0");
        vm.prank(ownerAddress);
        erc20Contract.mint(ownerAddress, 1000);
        assertEq(erc20Contract.balanceOf(ownerAddress), 1000, "Amount supposed to be 1000");
        vm.expectEmit(true, true, false, true);
        emit Transfer(ownerAddress ,recipient, 500);
        vm.prank(ownerAddress);
        erc20Contract.transfer(recipient, 500);
        assertEq(erc20Contract.balanceOf(ownerAddress), 500, "Amount supposed to be 500");
        assertEq(erc20Contract.balanceOf(recipient), 500, "Amount supposed to be 500");
    }

    function testRevert_transferRevertedifZeroAddress() public {
        assertEq(erc20Contract.balanceOf(ownerAddress), 0, "Amount supposed to be 0");
        vm.prank(ownerAddress);
        erc20Contract.mint(ownerAddress, 1000);
        assertEq(erc20Contract.balanceOf(ownerAddress), 1000, "Amount supposed to be 1000");
        vm.expectRevert(ERC20.InvalidRecipient.selector);
        vm.prank(ownerAddress);
        erc20Contract.transfer(address(0), 500);
        assertEq(erc20Contract.balanceOf(ownerAddress), 1000, "Amount supposed to be 500");
    }

    

    function test_TransferFrom() public {
        address recipient = address(0x2938);
        address caller = address(0x2373);
        uint256 amount = 500;
        // set msg.sender to owner address
        vm.startPrank(ownerAddress);
        // Mint 500 tokens to random address
        erc20Contract.mint(randomAddress, amount);
        // Verify tokens was minted successfully
        assertEq(erc20Contract.balanceOf(randomAddress), amount);
        // Stop prank
        vm.stopPrank();

        // testing event for approval
        vm.expectEmit(true, true, false, true);
        emit Approval(randomAddress, caller, amount);
        // Set msg.sender to random address
        vm.startPrank(randomAddress);
        // random address approves caller to spend `amount` tokens
        erc20Contract.approve(caller, amount);
        // Stop prank
        vm.stopPrank();

        assertEq(erc20Contract.balanceOf(recipient), 0);

        uint256 balanceOfSenderBeforeTransfer = erc20Contract.balanceOf(randomAddress);
        uint256 allowanceOfCallerBeforeTransfer = erc20Contract.allowance(randomAddress, caller);
        
        //testing events for transfer
        vm.expectEmit(true, true, false, true);
        emit Transfer(randomAddress, recipient, amount);

        vm.startPrank(caller);
        erc20Contract.transferFrom(randomAddress, recipient, amount);
        // recipient balance increased accordingly
        assertEq(erc20Contract.balanceOf(recipient), amount);
        // sender balance decrease accordingly
        uint256 balanceOfSenderAfterTransfer = erc20Contract.balanceOf(randomAddress);
        assertEq(balanceOfSenderBeforeTransfer - amount, balanceOfSenderAfterTransfer);

        uint256 allowanceOfCallerAfterTransfer = erc20Contract.allowance(randomAddress, caller);

        assertEq(allowanceOfCallerBeforeTransfer - amount, allowanceOfCallerAfterTransfer);
    }

    function test_changeOwner() public {
        address newowner = address(0x2938);
        vm.expectEmit(true, true, false, false);
        emit Owned(ownerAddress, newowner);
        vm.prank(ownerAddress);
        erc20Contract.changeOwner(newowner);
        assertEq(erc20Contract.owner(), newowner, "Owner not changed");        
    }

    function testRevert_changeOwnerShouldReverIfUnauthorized () public {
        address newowner = address(0x2938);      
        vm.expectRevert("Unauthorized");
        vm.prank(randomAddress);
        erc20Contract.changeOwner(newowner);
    }

    function test_Burn() public {
        vm.startPrank(ownerAddress);
        address add = address(0x2938);      
        assertEq(erc20Contract.balanceOf(add), 0, "Token balance should be 0");
        erc20Contract.mint(add, 1000);
        assertEq(erc20Contract.balanceOf(add), 1000, "Token balance should be 1000");
        erc20Contract.burn(add, 500);
        assertEq(erc20Contract.balanceOf(add), 500, "Token balance should be 500");
        vm.stopPrank();
    }
}