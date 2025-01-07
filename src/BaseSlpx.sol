// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {vETH} from "src/vETH.sol";
import {IGateway} from "src/IGateway.sol";

contract BaseSlpx is Ownable {
    IGateway public gateway;
    vETH public veth;
    uint128 public destinationFee;
    uint32 public paraId;
    uint256 public fee;


    constructor(address _gateway, address _veth, uint128 _destinationFee, uint32 _paraId, address _owner) Ownable(_owner) {
        gateway = IGateway(_gateway);
        veth = vETH(_veth);
        destinationFee = _destinationFee;
        paraId = _paraId;
    }

    /*//////////////////////////////////////////////////////////////
                            CORE LOGIC
    //////////////////////////////////////////////////////////////*/
    function mint() external payable {
        require(msg.value >= fee, "msg.value to low");
        uint256 exchangeRate = gateway.quoteExchangeRate(address(veth), paraId, destinationFee);
        veth.mint(msg.sender, msg.value * exchangeRate);
    }


    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/
    function setGateway(address _gateway) external onlyOwner {
        gateway = IGateway(_gateway);
    }


    function setVeth(address _veth) external onlyOwner {
        veth = vETH(_veth);
    }


    function setDestinationFee(uint128 _destinationFee) external onlyOwner {
        destinationFee = _destinationFee;
    }


    function setParaId(uint32 _paraId) external onlyOwner {
        paraId = _paraId;
    }
}
