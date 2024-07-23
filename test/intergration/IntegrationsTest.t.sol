// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol"; // 引入 Forge 标准库中的 Test 和 console
import {FundMe} from "../../src/FundMe.sol"; // 引入 FundMe 合约
import {DeployFundMe} from "../../script/DeployFundMe.s.sol"; // 引入部署脚本
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol"; // 引入 FundFundMe 和 WithdrawFundMe 脚本

contract IntegrationsTest is Test {
    FundMe fundMe; // 声明 FundMe 合约实例
    address USER = makeAddr("user"); // 伪造一个用户地址
    uint256 constant SEND_VALUE = 0.1 ether; // 定义发送的 ETH 数量为 0.1 ether
    uint256 constant STARTING_BALANCE = 10 ether; // 定义用户的起始余额为 10 ether

    // 设置测试环境
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe(); // 创建 DeployFundMe 实例
        fundMe = deployFundMe.run(); // 部署 FundMe 合约并获取实例
        vm.deal(USER, STARTING_BALANCE); // 给伪造的用户 10 个 ETH 作为起始资金
    }

    // 测试用户可以进行资金注入和提取的交互
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe(); // 创建 FundFundMe 实例
        //vm.prank(USER); // 设置下一笔交易的发送者为 USER（可选）
        //vm.deal(USER, 1e18); // 给 USER 发送 1 ether（可选）
        fundFundMe.fundFundMe(address(fundMe)); // 调用 fundFundMe 函数进行资金注入

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe(); // 创建 WithdrawFundMe 实例
        withdrawFundMe.withdrawFundMe(address(fundMe)); // 调用 withdrawFundMe 函数进行提款

        assert(address(fundMe).balance == 0); // 断言合约中的余额为 0
        //address funder = fundMe.getFunders(0); // 获取捐款者数组中的第一个地址（可选）
        //assertEq(funder, USER); // 测试捐款者是否为 USER（可选）
    }
}
