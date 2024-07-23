// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; // 引入 Forge 标准库中的 Test 和 console
import {FundMe} from "../../src/FundMe.sol"; // 引入 FundMe 合约
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // 引入部署脚本

contract FundMeTest is Test {
    FundMe fundMe; // 声明 FundMe 合约实例
    address USER = makeAddr("user"); // 伪造一个用户地址
    uint256 constant SEND_VALUE = 0.1 ether; // 定义发送的 ETH 数量为 0.1 ether
    uint256 constant STARTING_BALANCE = 10 ether; // 定义用户的起始余额为 10 ether

    // setUp 函数在每个测试运行之前执行，设置测试环境
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe(); // 创建 DeployFundMe 实例
        fundMe = deployFundMe.run(); // 部署 FundMe 合约并获取实例
        vm.deal(USER, STARTING_BALANCE); // 给伪造的用户 10 个 ETH 作为起始资金
    }

    // 测试 MINIMUM_USD 是否为 5e18（5 美元）
    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // 断言 MINIMUM_USD 是否等于 5e18
    }

    // 测试合约拥有者是否为消息发送者
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender); // 断言合约拥有者是否等于消息发送者
    }

    // 测试价格预言机版本是否正确
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion(); // 获取价格预言机的版本
        assertEq(version, 4); // 断言版本是否等于 4
    }

    // 测试在没有足够 ETH 的情况下捐款是否会失败
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // 期望交易回滚
        fundMe.fund(); // 尝试发送 0 value 的交易
    }

    // 测试捐款是否会更新捐款数据结构
    function testFundUpdatatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); // 获取用户捐款金额
        assertEq(amountFunded, SEND_VALUE); // 断言捐款金额是否正确
    }

    // 测试捐款者是否会被添加到捐款者数组中
    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunders(0); // 获取捐款者数组中的第一个地址
        assertEq(funder, USER); // 断言捐款者是否为 USER
    }

    // funded 修饰符，模拟捐款行为
    modifier funded() {
        vm.prank(USER); // 下一笔交易的发送者是 USER
        fundMe.fund{value: SEND_VALUE}(); // 发送 ETH 并调用 fund 函数
        _;
    }

    // 测试只有合约拥有者才能调用 withdraw 函数
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // 下一笔交易的发送者是 USER
        vm.expectRevert(); // 期望交易回滚
        fundMe.withdraw(); // 尝试调用 withdraw 函数
    }

    // 测试单一捐款者的提款操作
    function testWithDrawWithAsingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // 获取合约拥有者的余额
        uint256 startingFunderBalance = address(fundMe).balance; // 获取合约的余额
        // Act
        vm.prank(fundMe.getOwner()); // 下一笔交易的发送者是合约拥有者
        fundMe.withdraw(); // 调用 withdraw 函数
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // 获取提款后的合约拥有者余额
        uint256 endingFunderBalance = address(fundMe).balance; // 获取提款后的合约余额
        assertEq(endingFunderBalance, 0); // 断言合约的余额是否为 0
        assertEq(
            startingFunderBalance + startingOwnerBalance,
            endingOwnerBalance // 断言合约余额与合约拥有者余额之和是否等于提款后余额
        );
    }

    // 测试多个捐款者的提款操作
    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // 定义捐款者数量
        uint160 startingFunderIndex = 1; // 定义起始捐款者索引
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE); // 给每个捐款者初始余额
            fundMe.fund{value: SEND_VALUE}(); // 捐款
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // 获取合约拥有者的初始余额
        uint256 startingFunderBalance = address(fundMe).balance; // 获取合约的初始余额
        // Act
        vm.startPrank(fundMe.getOwner()); // 下一笔交易的发送者是合约拥有者
        fundMe.withdraw(); // 调用 withdraw 函数
        // Assert
        assertEq(address(fundMe).balance, 0); // 断言合约余额是否为 0
        assertEq(
            startingFunderBalance + startingOwnerBalance,
            fundMe.getOwner().balance // 断言合约余额与合约拥有者余额之和是否等于提款后余额
        );
    }
}
