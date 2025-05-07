// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IVToken} from "src/L2Slpx/IVToken.sol";
import {IZUSD} from "src/IZUSD.sol";
import {IL2Slpx} from "src/L2Slpx/IL2Slpx.sol";
import {ISimpleOracle} from "src/ISimpleOracle.sol";


contract ZekaeVault {
    uint256 public constant MIN_COLLATERAL_RATIO = 1.5e18;
    address public liquidator;

    IVToken public veth;
    IZUSD public zusd;
    IL2Slpx public l2Slpx;
    ISimpleOracle public oracle;
    
    error CollateralRatioIsLessThanMinimumCollateralRatio();
    error CollateralRatioIsGreaterOrEqualToMaximumCollateralRatio();

    mapping(address => uint256) public addressToDeposit;
    mapping(address => uint256) public addressToMinted;

    constructor(address _veth, address _zusd, address _l2Slpx, address _oracle, address _liquidator) {
        veth = IVToken(_veth);
        zusd = IZUSD(_zusd);
        l2Slpx = IL2Slpx(_l2Slpx);
        oracle = ISimpleOracle(_oracle);
        liquidator = _liquidator;
    }

    function deposit(uint256 amount) public {
        veth.transferFrom(msg.sender, address(this), amount);
        addressToDeposit[msg.sender] += amount;
    }

    function burn(uint256 amount) public {
        addressToMinted[msg.sender] -= amount;
        zusd.burn(msg.sender, amount);
    }

    function mint(uint256 amount) public {
        if (collateralRatio(msg.sender) < MIN_COLLATERAL_RATIO) {
            revert CollateralRatioIsLessThanMinimumCollateralRatio();
        }
        addressToMinted[msg.sender] += amount;

        zusd.mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        if (collateralRatio(msg.sender) < MIN_COLLATERAL_RATIO) {
            revert CollateralRatioIsLessThanMinimumCollateralRatio();
        }
        addressToDeposit[msg.sender] -= amount;
        veth.transfer(msg.sender, amount);
    }

    function liquidate(address user) public {
        if (collateralRatio(user) >= MIN_COLLATERAL_RATIO) {
            revert CollateralRatioIsGreaterOrEqualToMaximumCollateralRatio();
        }
        
        // Store values in memory
        uint256 userMinted = addressToMinted[user];
        
        // Calculate the amount of lstoken to be transferred to the liquidator
        uint256 amountOfLstokenToBeLiquidated = (userMinted * 1e18) / oracle.latestAnswer();

        // Update state before external calls
        addressToDeposit[user] -= amountOfLstokenToBeLiquidated;
        addressToMinted[user] = 0;
        
        // Perform external calls last
        zusd.burn(user, userMinted);
        veth.transfer(liquidator, amountOfLstokenToBeLiquidated);
    }

    function collateralRatio(address user) public view returns (uint256) {
        uint256 minted = addressToMinted[user];
        if (minted == 0) {
            return type(uint256).max;
        }
        uint256 totalValue = addressToDeposit[user] * oracle.latestAnswer();
        return totalValue / minted;
    }
}