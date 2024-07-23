// SPDX-License-Identifier: MIT

// fund - 资金注入
// withdraw - 提款

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

// 定义资金注入合约
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether; // 定义要发送的以太币数量为0.1 ether

    // 向指定地址的FundMe合约注入资金
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // 开始广播交易
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); // 向FundMe合约注入资金
        vm.stopBroadcast(); // 结束广播交易
        console.log("Funded FundMe with %s", SEND_VALUE); // 输出注入资金的数量
    }

    // 运行脚本，找到最近部署的FundMe合约并注入资金
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        ); // 获取最近部署的FundMe合约地址
        fundFundMe(mostRecentlyDeployed); // 注入资金到该合约
    }
}

// 提款合约的定义
contract WithdrawFundMe is Script {
    // 向指定地址的FundMe合约提取资金
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // 开始广播交易
        FundMe(payable(mostRecentlyDeployed)).withdraw(); // 从FundMe合约提取资金
        vm.stopBroadcast(); // 结束广播交易
    }

    // 运行脚本，找到最近部署的FundMe合约并提取资金
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        ); // 获取最近部署的FundMe合约地址
        withdrawFundMe(mostRecentlyDeployed); // 提取资金从该合约
    }
}
