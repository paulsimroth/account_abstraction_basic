// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MinAccount} from "src/ethereum/MinAccount.sol";
import {DeployMinAccount} from "script/DeployMinAccount.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/mocks/token/ERC20Mock.sol";
import {SendPackedUserOp, PackedUserOperation, IEntryPoint} from "script/SendPackedUserOp.s.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/utils/cryptography/MessageHashUtils.sol";

contract MinAccountTest is Test {
    using MessageHashUtils for bytes32;

    HelperConfig helperConfig;
    MinAccount minAccount;
    ERC20Mock usdc;
    SendPackedUserOp sendPackedUserOp;

    address randomUser = makeAddr("randomUser");

    uint256 constant AMOUNT = 1e18;

    function setUp() public {
        DeployMinAccount deployMinAccount = new DeployMinAccount();
        (helperConfig, minAccount) = deployMinAccount.deployMinAccount();
        usdc = new ERC20Mock();
        sendPackedUserOp = new SendPackedUserOp();
    }

    /**
     * @dev Test for USDC Mint
     * approve some amount on USDC contract
     * must come from EntryPoint
     */
    function testOwnerCAnExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minAccount), AMOUNT);

        // Act
        vm.prank(minAccount.owner());
        minAccount.execute(dest, value, funcData);

        // Assert
        assertEq(usdc.balanceOf(address(minAccount)), AMOUNT);
    }

    function testNonOwnerCannotExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minAccount), AMOUNT);

        // Act
        vm.prank(randomUser);

        // Assert
        vm.expectRevert(MinAccount.Account__NotFromEntryPointOrOwner.selector);
        minAccount.execute(dest, value, funcData);
    }

    function testRecoverSignedOp() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minAccount), AMOUNT);

        bytes memory executeCallData = abi.encodeWithSelector(MinAccount.execute.selector, dest, value, funcData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateSignedUserOp(executeCallData, helperConfig.getConfig(), address(minAccount));
        bytes32 userOpHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);

        // Act
        address signer = ECDSA.recover(userOpHash.toEthSignedMessageHash(), packedUserOp.signature);

        // Assert
        assertEq(signer, minAccount.owner());
    }

    function testValidationOfUserOps() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minAccount), AMOUNT);

        bytes memory executeCallData = abi.encodeWithSelector(MinAccount.execute.selector, dest, value, funcData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateSignedUserOp(executeCallData, helperConfig.getConfig(), address(minAccount));
        bytes32 userOpHash = IEntryPoint(helperConfig.getConfig().entryPoint).getUserOpHash(packedUserOp);
        uint256 missingAccountFunds = 1e18;

        // Act
        vm.prank(helperConfig.getConfig().entryPoint);
        uint256 validationData = minAccount.validateUserOp(packedUserOp, userOpHash, missingAccountFunds);

        // Assert
        assertEq(validationData, 0);
    }

    function testEntryPointCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minAccount)), 0);
        address dest = address(usdc);
        uint256 value = 0;
        bytes memory funcData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minAccount), AMOUNT);

        bytes memory executeCallData = abi.encodeWithSelector(MinAccount.execute.selector, dest, value, funcData);
        PackedUserOperation memory packedUserOp =
            sendPackedUserOp.generateSignedUserOp(executeCallData, helperConfig.getConfig(), address(minAccount));

        vm.deal(address(minAccount), 1e18);

        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = packedUserOp;

        // Act
        vm.prank(randomUser);
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, payable(randomUser));

        // Assert
        assertEq(usdc.balanceOf(address(minAccount)), AMOUNT);
    }
}
