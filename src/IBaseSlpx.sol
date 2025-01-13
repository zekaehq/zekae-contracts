// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IBaseSlpx {
    /*//////////////////////////////////////////////////////////////
                            CORE LOGIC
    //////////////////////////////////////////////////////////////*/
    
    function mint() external payable;

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/

    function desinationFee() external view returns (uint128);

    function paraId() external view returns (uint32);

    function fee() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            SETTERS
    //////////////////////////////////////////////////////////////*/

    function setGateway(address _gateway) external;

    function setVeth(address _veth) external;

    function setDestinationFee(uint128 _destinationFee) external;

    function setParaId(uint32 _paraId) external;
}
