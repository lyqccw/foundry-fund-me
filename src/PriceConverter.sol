// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Sepolia ETH / USD 地址
        // https://docs.chain.link/data-feeds/price-feeds/addresses

        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // ETH/USD 汇率，18位精度
        return uint256(answer * 10000000000); // 将价格转换为18位精度
    }

    // 将以太坊金额转换为美元金额
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // 获取当前ETH价格
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000; // 将ETH金额转换为USD金额
        // 实际的ETH/USD转换率，调整了额外的0
        return ethAmountInUsd; // 返回转换后的美元金额
    }
}
