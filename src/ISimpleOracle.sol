// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ISimpleOracle {
    /**
     * @notice Returns the latest price answer
     * @return The latest price answer
     */
    function latestAnswer() external view returns (uint256);

    /**
     * @notice Returns the L2Slpx contract address
     * @return The L2Slpx contract address
     */
    function l2Slpx() external view returns (address);

    /**
     * @notice Returns the VETH token address
     * @return The VETH token address
     */
    function VETH() external view returns (address);

    /**
     * @notice Sets the latest ETH price
     * @param _latestEthPrice The latest ETH price to set
     * @dev This function should only be callable by the owner
     */
    function setLatestAnswer(uint256 _latestEthPrice) external;
}
