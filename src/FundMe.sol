// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; // 指定Solidity版本

// 引入AggregatorV3Interface接口
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// 引入PriceConverter库
import {PriceConverter} from "./PriceConverter.sol";

// 自定义错误定义
error FundMe_NotOwner(); // 定义一个名为FundMe_NotOwner的错误

contract FundMe {
    using PriceConverter for uint256; // 使用PriceConverter库扩展uint256类型
    AggregatorV3Interface private s_priceFeed; // 价格预言机接口

    mapping(address => uint256) private s_addressToAmountFunded; // 记录每个地址的资金数额
    address[] private s_funders; // 存储所有捐款者的地址

    address private immutable i_owner; // 合约拥有者地址，immutable表示在合约部署后无法更改
    uint256 public constant MINIMUM_USD = 5e18; // 最小捐款额（以美元计）

    constructor(address priceFeed) {
        // 构造函数
        i_owner = msg.sender; // 部署合约的地址为合约拥有者
        s_priceFeed = AggregatorV3Interface(priceFeed); // 初始化价格预言机接口
    }

    function fund() public payable {
        // 捐款函数
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, // 确保捐款额不低于最小值
            "You need to spend more ETH!" // 如果不满足条件，抛出错误信息
        );
        s_addressToAmountFunded[msg.sender] += msg.value; // 更新捐款记录
        s_funders.push(msg.sender); // 添加捐款者地址到数组
    }

    function getVersion() public view returns (uint256) {
        // 获取价格预言机版本
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // 仅允许合约拥有者调用的修饰符
        if (msg.sender != i_owner) revert FundMe_NotOwner(); // 如果调用者不是合约拥有者，抛出错误
        _;
    }

    function withdraw() public onlyOwner {
        // 提取合约资金函数，仅合约拥有者可以调用
        for (
            uint256 funderIndex = 0; // 初始化索引
            funderIndex < s_funders.length; // 条件判断
            funderIndex++ // 索引递增
        ) {
            address funder = s_funders[funderIndex]; // 获取捐款者地址
            s_addressToAmountFunded[funder] = 0; // 将所有捐款者的捐款额归零
        }
        s_funders = new address[](0); // 重置捐款者数组

        // 使用call方法提取合约中的所有资金
        (bool callSuccess, ) = payable(msg.sender).call{ // 提取资金并发送给合约拥有者
            value: address(this).balance
        }(""); // 提取合约中所有余额
        require(callSuccess, "Call failed"); // 确认提取成功
    }

    // 以太被发送到合约
    //      msg.data 为空？
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        // fallback函数，当msg.data不为空时调用
        fund();
    }

    receive() external payable {
        // receive函数，当msg.data为空时调用
        fund();
    }

    function getAddressToAmountFunded(
        // 获取指定地址的捐款金额
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunders(uint256 index) external view returns (address) {
        // 获取捐款者地址
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        // 获取合约拥有者地址
        return i_owner;
    }
}
