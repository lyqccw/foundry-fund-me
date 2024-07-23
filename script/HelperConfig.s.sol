// SPDX-License-Identifier: MIT

// 1.当我们处于本地anvil时，我们将部署模拟合约，以便我们可以在本地测试我们的合约
// 2.我们将在不同的链上跟踪合约地址
// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.18; // 指定Solidity版本

import {Script} from "forge-std/Script.sol"; // 导入forge-std库中的Script合约
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol"; // 导入MockV3Aggregator合约

contract HelperConfig is
    Script // 定义HelperConfig合约，继承自Script
{
    NetworkConfig public activeNetworkConfig; // 定义一个public类型的activeNetworkConfig变量，用于存储当前网络配置
    uint8 public constant DECIMALS = 8; // 定义常量DECIMALS，表示小数位数
    int256 public constant INITIAL_PRICE = 2000e8; // 定义常量INITIAL_PRICE，表示初始价格

    struct NetworkConfig {
        // 定义NetworkConfig结构体
        address priceFeed; // ETH/USD价格喂价地址
    }

    constructor() {
        // 合约构造函数
        if (block.chainid == 11155111) {
            // 如果链ID为11155111（Sepolia测试网）
            activeNetworkConfig = getSepoliaEthConfig(); // 获取Sepolia网络配置
        } else if (block.chainid == 1) {
            // 如果链ID为1（主网）
            activeNetworkConfig = getMainnetEthConfig(); // 获取主网配置
        } else {
            // 否则
            activeNetworkConfig = getOrCreateAnvilEthConfig(); // 获取或创建Anvil本地区块链配置
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // 获取Sepolia网络配置
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // 设置Sepolia网络的ETH/USD价格喂价地址
        });
        return sepoliaConfig; // 返回Sepolia网络配置
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // 获取主网配置
        NetworkConfig memory mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 // 设置主网的ETH/USD价格喂价地址
        });
        return mainnetConfig; // 返回主网配置
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // 获取或创建Anvil本地区块链配置
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // 如果已有配置，直接返回
        }
        vm.startBroadcast(); // 开始广播事务
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); // 部署MockV3Aggregator合约，传入小数位数和初始价格
        vm.stopBroadcast(); // 停止广播事务

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) // 设置Anvil网络的ETH/USD价格喂价地址
        });
        return anvilConfig; // 返回Anvil网络配置
    }
}
