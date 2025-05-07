// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IL2Slpx} from "src/L2Slpx/IL2Slpx.sol";

contract SimpleOracle is Ownable {
    uint256 public latestAnswer;
    IL2Slpx public l2Slpx = IL2Slpx(0x262e52beD191a441CBD28dB151A11D7c41384F72);
    address public constant VETH = 0x6e0f9f2d25CC586965cBcF7017Ff89836ddeF9CC;

    constructor(address _owner) Ownable(_owner) {}

    function setLatestAnswer(uint256 _latestEthPrice) public onlyOwner {
        uint256 vethConversionRate = l2Slpx.getTokenConversionInfo(VETH).tokenConversionRate;
        latestAnswer = _latestEthPrice * 1e18 / vethConversionRate;
    }
}