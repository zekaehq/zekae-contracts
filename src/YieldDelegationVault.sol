// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {vETH} from "src/vETH.sol";
import {IXcmOracle} from "src/IXcmOracle.sol";


contract YieldDelegationVault is Ownable {
    IXcmOracle public ixcmOracle;
    vETH public veth;

    error InsufficientDeposit();

    mapping(address => uint256) public addressToUnderlyingToken;

    uint256 public ownerDelegatedDeposit;

    constructor(address _ixcmOracle, address _veth, address _owner) Ownable(_owner) {
        ixcmOracle = IXcmOracle(_ixcmOracle);
        veth = vETH(_veth);
    }

    function deposit(uint256 amount) external {
        veth.transferFrom(msg.sender, address(this), amount);
        uint256 amountOfUnderlyingToken = ixcmOracle.getTokenByVToken(address(veth), amount);
        addressToUnderlyingToken[msg.sender] += amountOfUnderlyingToken;
        ownerDelegatedDeposit += amount;
    }

    function withdraw(uint256 amount) external {
        if (addressToUnderlyingToken[msg.sender] < amount) {
            revert InsufficientDeposit();
        }
        uint256 amountOfUnderlyingToken = addressToUnderlyingToken[msg.sender];
        uint256 amountOfVToken = ixcmOracle.getVTokenByToken(address(veth), amountOfUnderlyingToken);
        addressToUnderlyingToken[msg.sender] = 0;
        veth.transfer(msg.sender, amountOfVToken);
    }

    function ownerWithdraw(uint256 amount) external onlyOwner {
        if (ownerDelegatedDeposit < amount) {
            revert InsufficientDeposit();
        }
        ownerDelegatedDeposit -= amount;
        veth.transfer(msg.sender, amount);
    }
}
