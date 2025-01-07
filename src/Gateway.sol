// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "@openzeppelin/contracts/access/Ownable.sol";


contract Gateway is Ownable {


    uint256 private sendTokenFee;

    uint256 private exchangeRate;


    constructor(uint256 _sendTokenFee, uint256 _exchangeRate, address initialOwner) Ownable(initialOwner) {
        sendTokenFee = _sendTokenFee;
        exchangeRate = _exchangeRate;
    }


    function quoteSendTokenFee(address token, uint32 paraId, uint128 destinationFee) external view returns (uint256) {
        // Basic validation to use the parameters
        require(token != address(0), "Invalid token address");
        require(paraId > 0, "Invalid paraId");
        require(destinationFee > 0, "Invalid destination fee");

        // mock the fee
        return sendTokenFee;
    }
        

    function setSendTokenFee(uint256 _fee) external onlyOwner returns (uint256) {
        sendTokenFee = _fee;
        return sendTokenFee;
    }

    function quoteExchangeRate(address token, uint32 paraId, uint128 destinationFee) external view returns (uint256) {
        require(token == address(0), "Invalid token address");
        require(paraId > 0, "Invalid paraId");
        require(destinationFee > 0, "Invalid destination fee");

        // mock the fee
        return exchangeRate;
    }

    function setExchangeRate(uint256 _rate) external onlyOwner returns (uint256) {
        exchangeRate = _rate;
        return exchangeRate;
    }

}
