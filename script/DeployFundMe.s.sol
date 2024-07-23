// SPDX-License-Identifier: MIT
// 指定许可证信息

pragma solidity ^0.8.19;
// 指定Solidity版本

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// 导入必要的库和合约

contract DeployFundMe is Script {
    // 定义部署合约

    function run() external returns (FundMe) {
        // 定义一个run函数，用于部署合约，返回一个FundMe合约实例

        HelperConfig helperConfig = new HelperConfig();
        // 创建一个HelperConfig实例，用于获取配置

        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // 获取当前网络配置中的ETH/USD价格喂价地址

        vm.startBroadcast();
        // 开始广播事务

        FundMe fundme = new FundMe(ethUsdPriceFeed);
        // 部署FundMe合约，传入ETH/USD价格喂价地址

        vm.stopBroadcast();
        // 停止广播事务

        return fundme;
        // 返回部署的FundMe合约实例
    }
}
