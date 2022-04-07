// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import {OwnerPausable} from "ac/util/OwnerPausable.sol";
import {Strings} from "oz/utils/Strings.sol";
import {ERC1155} from "oz/token/ERC1155/ERC1155.sol";
import {FactoryMintable} from "./FactoryMintable.sol";
import {AllowsProxyFromConfigurableRegistry} from "ac/util/AllowsProxyFromConfigurableRegistry.sol";
import {TokenFactory} from "./TokenFactory.sol";

abstract contract FactoryMintableERC1155 is
    ERC1155,
    OwnerPausable,
    FactoryMintable,
    AllowsProxyFromConfigurableRegistry
{
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        address _proxyAddress,
        string memory _baseOptionURI,
        uint256 _numOptions
    )
        ERC1155(_baseUri)
        AllowsProxyFromConfigurableRegistry(_proxyAddress, true)
    {
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
}
