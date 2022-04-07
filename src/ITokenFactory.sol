// SPDX-License-Identifier: MIT
// Modified 2022 from github.com/divergencetech/ethier
pragma solidity >=0.8.4;

/// @author emo.eth
interface ITokenFactory {
    function transferFrom(
        address,
        address _to,
        uint256 _optionId
    ) external;

    function safeTransferFrom(
        address,
        address _to,
        uint256 _optionId
    ) external;

    function isApprovedForAll(address _owner, address _operator)
        external
        returns (bool);

    function ownerOf(uint256 _optionId) external returns (address);

    function tokenURI(uint256 _optionId) external returns (string memory);

    function restoreOption(uint256 _optionId) external;

    function burnInvalidOptions() external;
}
