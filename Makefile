-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil zktest

# 默认的 Anvil 私钥
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# 默认的 zkSync 本地私钥
DEFAULT_ZKSYNC_LOCAL_KEY := 0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110

# 定义所有目标任务
all: clean remove install update build

# 清理项目
clean:; forge clean

# 删除模块
remove:; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# 安装依赖
install:; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit

# 更新依赖
update:; forge update

# 构建项目
build:; forge build

# zkSync 构建
zkbuild:; forge build --zksync

# 运行测试
test:; forge test

# zkSync 测试
zktest:; foundryup-zksync && forge test --zksync && foundryup

# 生成快照
snapshot:; forge snapshot

# 格式化代码
format:; forge fmt

# 启动 Anvil 节点
anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# 启动 zkSync Anvil 节点
zk-anvil:; npx zksync-cli dev start

# 部署合约
deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

# 默认网络参数
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# 如果参数中包含 --network sepolia，则使用不同的网络参数
ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

# 部署到 Sepolia 网络
deploy-sepolia:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(SEPOLIA_RPC_URL)

# 部署到 zkSync 网络
deploy-zk:
	forge create src/FundMe.sol:FundMe --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args $(shell forge create test/mock/MockV3Aggregator.sol:MockV3Aggregator --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args 8 200000000000 --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --legacy --zksync

# 部署到 zkSync Sepolia 网络
deploy-zk-sepolia:
	forge create src/FundMe.sol:FundMe --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account default --constructor-args 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF --legacy --zksync

# 部署和交互脚本的发送者地址
SENDER_ADDRESS := <sender's address>
 
# 资金注入
fund:
	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

# 提款
withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)
