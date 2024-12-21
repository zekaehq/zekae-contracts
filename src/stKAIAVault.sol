// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "src/ERC20.sol";
import {IKUSD} from "src/IKUSD.sol";

contract stKAIAVault {
    uint256 public constant MIN_COLLAT_RATIO = 1.5e18;

    ERC20 public stkaia; // mock stKAIA for testing
    IKUSD public vusd;

    uint256 constant yield = 3e14; // mock yield per second 0.0003
    uint256 public vaultCreationTime;
    uint256 public stKAIAPriceAtCreation;

    mapping(address => uint256) public addressToDeposit;
    mapping(address => uint256) public addressToMinted;

    constructor(address _stkaia, address _kusd, uint256 _stKAIAPriceAtCreation) {
        stkaia = ERC20(_stkaia);
        vusd = IKUSD(_kusd);
        vaultCreationTime = block.timestamp;
        stKAIAPriceAtCreation = _stKAIAPriceAtCreation;
    }

    function deposit(uint256 amount) public {
        stkaia.transferFrom(msg.sender, address(this), amount);
        addressToDeposit[msg.sender] += amount;
    }

    function burn(uint256 amount) public {
        addressToMinted[msg.sender] -= amount;
        vusd.burn(msg.sender, amount);
    }

    function mint(uint256 amount) public {
        addressToMinted[msg.sender] += amount;
        require(collateralRatio(msg.sender) >= MIN_COLLAT_RATIO);
        vusd.mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        addressToDeposit[msg.sender] -= amount;
        require(collateralRatio(msg.sender) >= MIN_COLLAT_RATIO);
        stkaia.transfer(msg.sender, amount);
    }

    function liquidate(address user) public {
        require(collateralRatio(user) < MIN_COLLAT_RATIO);
        vusd.burn(msg.sender, addressToMinted[user]);
        stkaia.transfer(msg.sender, addressToDeposit[user]);
        addressToDeposit[user] = 0;
        addressToMinted[user] = 0;
    }

    function getVWNDCurrentPrice() public view returns (uint256) {
        // calculate how many seconds have passed since the vault was created
        uint256 secondsPassed = block.timestamp - vaultCreationTime;
        // calculate the current price of stKAIA
        uint256 stKAIACurrentPrice = (secondsPassed * yield) + stKAIAPriceAtCreation;
        return stKAIACurrentPrice;
    }

    function collateralRatio(address user) public view returns (uint256) {
        uint256 minted = addressToMinted[user];
        if (minted == 0) return type(uint256).max;
        uint256 totalValue = addressToDeposit[user] * getVWNDCurrentPrice();
        return totalValue / minted;
    }
}
