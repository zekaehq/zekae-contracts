// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title IVToken Interface
/// @notice Interface for vTokens that are burnable and mintable ERC20 tokens
interface IVToken is IERC20 {
    /// @notice Mints tokens to an address
    /// @param to The address to mint tokens to
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) external;

    /// @notice Burns tokens from an address
    /// @param amount The amount of tokens to burn
    function burn(uint256 amount) external;
}
