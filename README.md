# Zekae Contracts
> Yield bearing stablecoin zUSD leveraging LST

## Features
- Feature 1: Deposit and withdraw LST from Vault used as collateral for stablecoins
- Feature 2: Mint stablecoins using LST as collateral
- Feature 3: Liquidate LST from Vault when collateral ratio is below threshold
- Feature 4: An oracle for the price of the underlying asset and exchange rate

## How It Works
### Architecture
#### LST token contract
An ERC20 token contract that is representative of the LST that will be available on Asset Hub.

#### zUSD contract
An ERC20 token contract that is a stablecoin and has the vault as the owner (the only one who can mint and burn).

#### ZeKaeVault contract
A contract that allows users to deposit LST, withdraw LST, mint zUSD and burn zUSD. Additionally, it has a liquidation function that allows the liquidators to liquidate LST from the user when the collateral ratio is below threshold. The collateral ratio is set at 150% for now.

#### Revelant functions:

- `deposit(uint256 amount)`
- `withdraw(uint256 amount)`
- `mint(uint256 amount)`
- `burn(uint256 amount)`
- `liquidate(address user)`



