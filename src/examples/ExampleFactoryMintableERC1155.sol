// SPDX-License-Identifier: MIT
// Modified 2022 from github.com/divergencetech/ethier
pragma solidity ^0.8.12;

import {FactoryMintableERC1155} from "../FactoryMintableERC1155.sol";
import {ReentrancyGuard} from "sm/utils/ReentrancyGuard.sol";

contract ExampleFactoryMintableERC1155 is
    FactoryMintableERC1155,
    ReentrancyGuard
{
    uint256 public tokenIndex;
    uint256 public maxSupply;

    error NewMaxSupplyMustBeGreater();

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        uint256 _maxSupply,
        address _proxyAddress,
        string memory _baseOptionURI,
        uint256 _numOptions
    )
        FactoryMintableERC1155(
            _name,
            _symbol,
            _baseUri,
            _proxyAddress,
            _baseOptionURI,
            _numOptions
        )
    {
        maxSupply = _maxSupply;
    }

    function factoryMint(uint256 _optionId, address _to)
        public
        override
        nonReentrant
        onlyFactory
        canMint(_optionId)
    {
        for (uint256 i; i < _optionId; i++) {
            _mint(_to, tokenIndex, 1, "");
            ++tokenIndex;
        }
    }

    function factoryCanMint(uint256 _optionId)
        public
        view
        virtual
        override
        returns (bool)
    {
        if (_optionId == 0 || _optionId > maxSupply) {
            return false;
        }
        if (_optionId > (maxSupply - tokenIndex)) {
            return false;
        }
        return true;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        if (_maxSupply <= maxSupply) {
            revert NewMaxSupplyMustBeGreater();
        }
        maxSupply = _maxSupply;
    }
}
