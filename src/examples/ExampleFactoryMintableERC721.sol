// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;

import {FactoryMintableERC721} from "../FactoryMintableERC721.sol";
import {ReentrancyGuard} from "sm/utils/ReentrancyGuard.sol";
import {Strings} from "oz/utils/Strings.sol";

contract ExampleFactoryMintableERC721 is
    FactoryMintableERC721,
    ReentrancyGuard
{
    using Strings for uint256;

    uint256 public tokenIndex;
    uint256 public maxSupply;

    error NewMaxSupplyMustBeGreater();

    constructor(
        uint256 _maxSupply,
        address _proxy,
        uint256 _numOptions
    )
        FactoryMintableERC721(
            "test",
            "TEST",
            "ipfs://test",
            _proxy,
            "ipfs://option",
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
        for (uint256 i; i < _optionId; ++i) {
            _mint(_to, tokenIndex);
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
