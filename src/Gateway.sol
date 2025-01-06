// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract Gateway {

    uint256 sendTokenFee = 1000000;

    function quoteSendTokenFee(address token, uint32 paraId, uint128 destinationFee) external view returns (uint256) {
        // Basic validation to use the parameters
        require(token != address(0), "Invalid token address");
        require(paraId > 0, "Invalid paraId");
        require(destinationFee > 0, "Invalid destination fee");

        // mock the fee
        return sendTokenFee;
    }
        

    function setSendTokenFee(uint256 _fee) external {
        sendTokenFee = _fee;
    }

}
