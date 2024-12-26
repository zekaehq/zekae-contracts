// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "src/ERC20.sol";
import {IZUSD} from "src/IZUSD.sol";

contract ZekaeVault {
    uint256 public constant MIN_COLLAT_RATIO = 1.5e18;

    ERC20 public lstoken; // mock stKAIA for testing
    IZUSD public zusd;

    uint256 constant yield = 3e14; // mock yield per second 0.0003
    uint256 public vaultCreationTime;
    uint256 public lstokenPriceAtCreation;

    mapping(address => uint256) public addressToDeposit;
    mapping(address => uint256) public addressToMinted;

    constructor(address _lstoken, address _zusd, uint256 _lstokenPriceAtCreation) {
        lstoken = ERC20(_lstoken);
        zusd = IZUSD(_zusd);
        vaultCreationTime = block.timestamp;
        lstokenPriceAtCreation = _lstokenPriceAtCreation;
    }

    function deposit(uint256 amount) public {
        lstoken.transferFrom(msg.sender, address(this), amount);
        addressToDeposit[msg.sender] += amount;
    }

    function burn(uint256 amount) public {
        addressToMinted[msg.sender] -= amount;
        zusd.burn(msg.sender, amount);
    }

    function mint(uint256 amount) public {
        addressToMinted[msg.sender] += amount;
        require(collateralRatio(msg.sender) >= MIN_COLLAT_RATIO);
        zusd.mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        addressToDeposit[msg.sender] -= amount;
        require(collateralRatio(msg.sender) >= MIN_COLLAT_RATIO);
        lstoken.transfer(msg.sender, amount);
    }

    function liquidate(address user) public {
        require(collateralRatio(user) < MIN_COLLAT_RATIO);
        zusd.burn(msg.sender, addressToMinted[user]);
        lstoken.transfer(msg.sender, addressToDeposit[user]);
        addressToDeposit[user] = 0;
        addressToMinted[user] = 0;
    }

    function getLSTokenCurrentPrice() public view returns (uint256) {
        // calculate how many seconds have passed since the vault was created
        uint256 secondsPassed = block.timestamp - vaultCreationTime;
        // calculate the current price of stKAIA
        uint256 lstokenCurrentPrice = (secondsPassed * yield) + lstokenPriceAtCreation;
        return lstokenCurrentPrice;
    }

    function collateralRatio(address user) public view returns (uint256) {
        uint256 minted = addressToMinted[user];
        if (minted == 0) return type(uint256).max;
        uint256 totalValue = addressToDeposit[user] * getLSTokenCurrentPrice();
        return totalValue / minted;
    }
}
