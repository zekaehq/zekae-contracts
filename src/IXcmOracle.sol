// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title IXcmOracle Interface
/// @notice Interface for the XCM Oracle that handles cross-chain message verification
interface IXcmOracle {

    struct PoolInfo {
        address token;
        uint256 balance;
        // Add other necessary fields based on your requirements
    }

    struct RateInfo {
        uint8 mintRate;
        uint8 redeemRate;
    }

    /// @notice Event emitted when a new message hash is registered
    event MessageHashRegistered(bytes32 indexed messageHash, uint64 indexed sourceChainId);

    /// @notice Event emitted when a message is verified
    event MessageVerified(bytes32 indexed messageHash, uint64 indexed sourceChainId);

    /// @notice Returns the owner address of the contract
    /// @return address The owner address
    function owner() external view returns (address);

    /// @notice Returns the sovereign address
    /// @return address The sovereign address
    function sovereignAddress() external view returns (address);

    /// @notice Returns the slx address
    /// @return address The slx address
    function slxAddress() external view returns (address);

    /// @notice Returns the token pool for a given currency ID
    /// @param currencyId The currency ID
    /// @return PoolInfo The token pool information
    function tokenPool(bytes2 currencyId) external view returns (PoolInfo memory);

    /// @notice Returns the rate info
    /// @return RateInfo The rate information
    function rateInfo() external view returns (RateInfo memory);

    /// @notice Returns the mapping of message hash and chain ID to registration timestamp
    /// @param messageHash The hash of the cross-chain message
    /// @param sourceChainId The ID of the chain where the message originated
    /// @return uint256 The timestamp when the message was registered
    function messages(bytes32 messageHash, uint64 sourceChainId) external view returns (uint256);

    /// @notice Returns the mapping of message hash and chain ID to verification status
    /// @param messageHash The hash of the cross-chain message
    /// @param sourceChainId The ID of the chain where the message originated
    /// @return bool The verification status of the message
    function verifiedMessages(bytes32 messageHash, uint64 sourceChainId) external view returns (bool);

    /// @notice Registers a new message hash from a source chain
    /// @param messageHash The hash of the cross-chain message
    /// @param sourceChainId The ID of the chain where the message originated
    function registerMessageHash(bytes32 messageHash, uint64 sourceChainId) external;

    /// @notice Verifies if a message hash has been registered and is valid
    /// @param messageHash The hash of the cross-chain message to verify
    /// @param sourceChainId The ID of the chain where the message originated
    /// @return bool True if the message is verified, false otherwise
    function verifyMessage(bytes32 messageHash, uint64 sourceChainId) external view returns (bool);

    /// @notice Gets the timestamp when a message was registered
    /// @param messageHash The hash of the cross-chain message
    /// @param sourceChainId The ID of the chain where the message originated
    /// @return uint256 The timestamp when the message was registered (0 if not registered)
    function getMessageTimestamp(bytes32 messageHash, uint64 sourceChainId) external view returns (uint256);

    /// @notice Checks if a message hash exists
    /// @param messageHash The hash of the cross-chain message
    /// @param sourceChainId The ID of the chain where the message originated
    /// @return bool True if the message exists, false otherwise
    function messageExists(bytes32 messageHash, uint64 sourceChainId) external view returns (bool);
}
