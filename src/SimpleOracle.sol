// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IL2Slpx} from "src/L2Slpx/IL2Slpx.sol";

contract SimpleOracle is Ownable {
    uint256 public latestAnswer;
    IL2Slpx public l2Slpx;
    address public VETH;

    constructor(address _owner, address _l2Slpx, address _veth) Ownable(_owner) {
        l2Slpx = IL2Slpx(_l2Slpx);
        VETH = _veth;
    }

    function setLatestAnswer(uint256 _latestEthPrice) public onlyOwner {
        uint256 vethConversionRate = l2Slpx.getTokenConversionInfo(VETH).tokenConversionRate;
        latestAnswer = _latestEthPrice * 1e18 / vethConversionRate;
    }
}