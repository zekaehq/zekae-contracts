-include .env

build:
	forge build

test-all:
	forge test -vvvv

deploy-base:
	forge script script/Deploy.s.sol --rpc-url ${BASE_RPC_URL} --account dev --sender ${SENDER} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

deploy-base-sepolia:
	forge script script/Deploy.s.sol --rpc-url ${BASE_SEPOLIA_RPC_URL} --account dev --sender ${SENDER} --broadcast --verify -vvvv