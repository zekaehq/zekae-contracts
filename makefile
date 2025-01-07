-include .env

build:
	forge build

test-all:
	forge test -vvvv

deploy-mainnet:
	forge script script/Deploy.s.sol --rpc-url ${BASE_RPC} --account dev --sender ${SENDER} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

deploy-testnet:
	forge script script/Deploy.s.sol --rpc-url ${BASE_SEPOLIA_RPC} --account dev --sender ${SENDER} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

interact:
	forge script script/Interactions.s.sol --rpc-url ${BASE_SEPOLIA_RPC} --account dev --sender ${SENDER} --broadcast -vvvv