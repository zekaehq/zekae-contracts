// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {vETH} from "src/vETH.sol";
import {IGateway} from "src/IGateway.sol";
import {IXcmOracle} from "src/IXcmOracle.sol";
import {BaseSlpx} from "src/BaseSlpx.sol";


contract YieldDelegationVault is Ownable {
    IGateway public gateway;
    vETH public veth;
    uint128 public destinationFee; // set at 1000000
    uint32 public paraId; // set at 2030
    uint256 public fee; // set at 1000000

    constructor(address _gateway, address _veth, uint128 _destinationFee, uint128 _fee, uint32 _paraId, address _owner)
        Ownable(_owner)
    {
        gateway = IGateway(_gateway);
        veth = vETH(_veth);
        destinationFee = _destinationFee;
        fee = _fee;
        paraId = _paraId;
    }
}
