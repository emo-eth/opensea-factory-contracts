// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IFactoryMintable} from "./IFactoryMintable.sol";

abstract contract FactoryMintable is IFactoryMintable, Context {
    address public immutable tokenFactory;

    // this abstract class needs its own constructor so tokenFactory can be marked immutable, saving gas when reading
    constructor(address _tokenFactory) {
        tokenFactory = _tokenFactory;
    }

    error NotTokenFactory();
    error FactoryCannotMint();

    modifier onlyFactory() {
        if (_msgSender() != tokenFactory) {
            revert NotTokenFactory();
        }
        _;
    }

    modifier canMint(uint256 _optionId) {
        if (!factoryCanMint(_optionId)) {
            revert FactoryCannotMint();
        }
        _;
    }

    function factoryMint(uint256 _optionId, address _to) external virtual;

    function factoryCanMint(uint256 _optionId)
        public
        view
        virtual
        returns (bool);
}
