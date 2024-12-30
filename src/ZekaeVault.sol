// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "src/ERC20.sol";
import {IZUSD} from "src/IZUSD.sol";
import {ISimpleMockOracle} from "src/ISimpleMockOracle.sol";

contract ZekaeVault {
    uint256 public constant MIN_COLLAT_RATIO = 1.5e18;

    ERC20 public lstoken; // mock stKAIA for testing
    IZUSD public zusd;

    ISimpleMockOracle public oracle;

    mapping(address => uint256) public addressToDeposit;
    mapping(address => uint256) public addressToMinted;

    constructor(address _lstoken, address _zusd, address _oracle) {
        lstoken = ERC20(_lstoken);
        zusd = IZUSD(_zusd);
        oracle = ISimpleMockOracle(_oracle);
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

    function collateralRatio(address user) public view returns (uint256) {
        uint256 minted = addressToMinted[user];
        if (minted == 0) return type(uint256).max;
        uint256 totalValue = addressToDeposit[user] * (oracle.latestAnswer() / 1e18);
        return totalValue / minted;
    }
}
