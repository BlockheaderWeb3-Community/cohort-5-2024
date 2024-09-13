// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC20} from "../src/ERC20.sol";

contract ERC20ContractTest is Test {
    ERC20 public erc20contract;
    address ownerAddress = address(0x0101);
    address scammer = address(0x9987);
    address randomAddress = address(0x9333);
    address recipient = address(0x5676);
    address caller = address(0x2575);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Owned(address indexed old, address indexed newAddress);

    error InvalidRecipient();
    error InsufficientBalance();

    function setUp() public {
        vm.prank(ownerAddress); // address deploying the contract
        erc20contract = new ERC20("MyToken", "MTK", 0);
    }

    function test_ContractDeployedSuccessfully() public view {
        assertEq(erc20contract.name(), "MyToken");
        assertEq(erc20contract.symbol(), "MTK");
        assertEq(erc20contract.decimals(), 0);
        console.log(erc20contract.decimals());
    }

    function testFail_OwnerIsSetCorrectly() public view {
        address notOwner = address(0x9998);
        assertEq(
            erc20contract.owner(), 
            notOwner,
            "owner address not set correctly"
        );
    }

    function test_MintRevertByNonOwner() public {
        vm.startPrank(scammer);
        vm.expectRevert("Unauthorized");
        erc20contract.mint(scammer, 1000);
        vm.stopPrank();
    }

    function test_MintWillRevertWhenTryingToMintToAddressZero() public {
        vm.prank(ownerAddress);
        vm.expectRevert(InvalidRecipient.selector);
        erc20contract.mint(address(0), 1000);
    }

    function test_MintWasSuccessful() public {
        uint256 totalSupplyBeforeMint = erc20contract.totalSupply();
        uint256 mintAmount = 1000;
        // check balance before mint
        assertEq(
            erc20contract.balanceOf(randomAddress),
            0,
            "expected random address balance to be 0"
        );
        // Set the msg.sender to the 'ownerAddress'
        vm.prank(ownerAddress);
        // mint to randomAddress
        erc20contract.mint(randomAddress, mintAmount);

        uint256 totalSupplyAfterMint = erc20contract.totalSupply();
         // check balance before mint
        assertEq(
            erc20contract.balanceOf(randomAddress),
            1000,
            "expected random address balance to be 1000"
        );
        assertEq(totalSupplyBeforeMint + mintAmount, totalSupplyAfterMint);
    }

    function test_TransferFrom() public {
        uint256 amount = 500;

        vm.startPrank(ownerAddress);
        erc20contract.mint(randomAddress, 500);
        assertEq(erc20contract.balanceOf(randomAddress), 500);
        vm.stopPrank();

        vm.startPrank(randomAddress);
        erc20contract.approve(caller, amount);
        vm.stopPrank();

        assertEq(erc20contract.balanceOf(recipient), 0);

        uint256 balanceOfSenderBeforeTransfer = erc20contract.balanceOf(randomAddress);

        uint256 allowanceOfCallerBeforeTransfer = erc20contract.allowance(randomAddress, caller);

        vm.startPrank(caller);
        erc20contract.transferFrom(randomAddress, recipient, amount);
        
        // recipient address increase successfully
        assertEq(erc20contract.balanceOf(recipient), amount);
        // randomAddress decrease successfully
        uint256 balanceOfSenderAfterTransfer = erc20contract.balanceOf(randomAddress);
        uint256 allowanceOfCallerAfterTransfer = erc20contract.allowance(randomAddress, caller);
        assertEq(
            balanceOfSenderBeforeTransfer - amount, balanceOfSenderAfterTransfer
        );
        assertEq(
            allowanceOfCallerBeforeTransfer - amount,
            allowanceOfCallerAfterTransfer
        );
    }

    function test_Approval() public {
        vm.startPrank(ownerAddress);

        uint amount = 3000;
        erc20contract.mint(ownerAddress, amount);
        assertEq(erc20contract.balanceOf(ownerAddress), amount);

        vm.expectRevert(InvalidRecipient.selector);
        erc20contract.approve(address(0), 2000);

        vm.stopPrank();
    }

    function test_SuccessFulApproval() public {
        vm.startPrank(ownerAddress);

        uint amount = 3000;

        uint allowanceBefore = erc20contract.allowance(ownerAddress, randomAddress);
        assertEq(allowanceBefore, 0);

        erc20contract.mint(ownerAddress, amount);
        assertEq(erc20contract.balanceOf(ownerAddress), amount);

        erc20contract.approve(randomAddress, amount);
        uint allowanceAfter = erc20contract.allowance(ownerAddress, randomAddress);
        assertEq(allowanceAfter, amount);

        vm.stopPrank();
    }


    function test_Transfer() public {
        vm.startPrank(randomAddress);
        vm.expectRevert(InsufficientBalance.selector);
        erc20contract.transfer(recipient, 1000);
        vm.stopPrank();

        vm.startPrank(ownerAddress);
        uint amount = 3000;

        uint ownerBalanceBeforeMint = erc20contract.balanceOf(ownerAddress);

        uint recipientBalanceBeforeTransfer = erc20contract.balanceOf(recipient);

        erc20contract.mint(ownerAddress, amount);

        uint ownerBalanceAfterMint = erc20contract.balanceOf(ownerAddress);
        assertEq(ownerBalanceBeforeMint + amount, ownerBalanceAfterMint);

        erc20contract.transfer(recipient, 1000);
        
        uint recipientBalanceAfterTransfer = erc20contract.balanceOf(recipient);
        assertEq(recipientBalanceBeforeTransfer + 1000, recipientBalanceAfterTransfer);

        vm.stopPrank();
    }

    function test_changeOwner() public {
        vm.startPrank(randomAddress);
        vm.expectRevert("Unauthorized");
        erc20contract.changeOwner(recipient);
        vm.stopPrank();

        vm.startPrank(ownerAddress);
        erc20contract.changeOwner(randomAddress);
        assertEq(erc20contract.owner(), randomAddress);
        vm.stopPrank();
    }

    function test_Burn() public {
        uint amount = 1000;
        vm.startPrank(ownerAddress);
        erc20contract.mint(recipient, amount);
        erc20contract.burn(recipient, 20);
        assertEq(erc20contract.balanceOf(recipient), amount - 20);
        vm.stopPrank();

        vm.startPrank(randomAddress);
        vm.expectRevert("Unauthorized");
        erc20contract.burn(recipient, 20);
        vm.stopPrank();
    }

    // EVENTS
    function test_TransferEvents() public {
        vm.startPrank(ownerAddress);

        erc20contract.mint(randomAddress, 1000);
        assertEq(erc20contract.balanceOf(randomAddress), 1000);

        vm.stopPrank();

        vm.startPrank(randomAddress);
        vm.expectEmit(true, true, false, true);
        emit Transfer(randomAddress, recipient, 500);
        erc20contract.transfer(recipient, 500);
        vm.stopPrank();
    }

    function test_ApprovalEvents() public {
        vm.startPrank(ownerAddress);
        vm.expectEmit(true, true, false, true);
        emit Approval(ownerAddress, randomAddress, 1000);
        erc20contract.approve(randomAddress, 1000);
        vm.stopPrank();
    }

    function test_TransferFromEvents() public {
        vm.startPrank(ownerAddress);

        erc20contract.mint(ownerAddress, 1000);
        assertEq(erc20contract.balanceOf(ownerAddress), 1000);
        
        erc20contract.approve(randomAddress, 500);
        vm.stopPrank();

        vm.startPrank(randomAddress);
        vm.expectEmit(true, true, false, true);
        emit Transfer(ownerAddress, recipient, 500);
        erc20contract.transferFrom(ownerAddress, recipient, 500);

        assertEq(erc20contract.balanceOf(recipient), 500);
        vm.stopPrank();
    }

    function test_MintEvents() public {
        vm.startPrank(ownerAddress);
        uint totalSupplyBeforeMint = erc20contract.totalSupply();
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), randomAddress, 1000);
        erc20contract.mint(randomAddress, 1000);

        uint totalSupplyAfterMint = erc20contract.totalSupply();
        assertEq(erc20contract.balanceOf(randomAddress), 1000);
        assertEq(totalSupplyBeforeMint + 1000, totalSupplyAfterMint);
        vm.stopPrank();
    }

    function test_BurnEvents() public {
        // uint totalSupply = erc20contract.totalSupply();

        vm.startPrank(ownerAddress);

        erc20contract.mint(randomAddress, 1000);
        assertEq(erc20contract.balanceOf(randomAddress), 1000);
        assertEq(erc20contract.totalSupply(), 1000);

        vm.expectEmit(true, true, false, true);
        emit Transfer(randomAddress, address(0), 500);
        erc20contract.burn(randomAddress, 500);

        assertEq(erc20contract.totalSupply(), 500);
        vm.stopPrank();
    }

    function test_ChangeOwnerEvent() public {
        vm.startPrank(ownerAddress);
        vm.expectEmit(true, true, false, false);
        emit Owned(ownerAddress, randomAddress);
        erc20contract.changeOwner(randomAddress);
        vm.stopPrank();

        assertEq(erc20contract.owner(), randomAddress);
    }
}

