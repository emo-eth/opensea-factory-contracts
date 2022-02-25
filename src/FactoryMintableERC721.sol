// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import {OwnerPausable} from "ac/util/OwnerPausable.sol";
import {Strings} from "oz/utils/Strings.sol";
import {ERC721} from "oz/token/ERC721/ERC721.sol";
import {FactoryMintable} from "./FactoryMintable.sol";
import {AllowsConfigurableProxy} from "ac/util/AllowsConfigurableProxy.sol";
import {TokenFactory} from "./TokenFactory.sol";

abstract contract FactoryMintableERC721 is
    ERC721,
    OwnerPausable,
    FactoryMintable,
    AllowsConfigurableProxy
{
    string public baseURI;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        address _proxyAddress,
        string memory _baseOptionURI,
        uint256 _numOptions
    ) ERC721(_name, _symbol) AllowsConfigurableProxy(_proxyAddress, true) {
        baseURI = _baseUri;
        tokenFactory = address(
            new TokenFactory(
                string.concat(_name, " Factory"),
                string.concat(_symbol, "FACTORY"),
                _baseOptionURI,
                owner(),
                _numOptions,
                _proxyAddress
            )
        );
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
