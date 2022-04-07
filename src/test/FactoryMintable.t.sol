// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "ac/test/helpers/DSTestPlusPlus.sol";
import {stdCheats, stdError, Vm} from "std/stdlib.sol";
import {FactoryMintable} from "../FactoryMintable.sol";
import {TokenFactory} from "../TokenFactory.sol";

contract FactoryMintableImpl is FactoryMintable {
    uint256 public immutable MAX_OPTION_ID;
    uint256 public tokenIndex;

    constructor(uint256 _maxOptionId) {
        tokenFactory = address(
            new TokenFactory(
                "test",
                "TEST",
                "://test",
                msg.sender,
                _maxOptionId,
                address(1234)
            )
        );
        MAX_OPTION_ID = _maxOptionId;
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function factoryMint(uint256 _optionId, address)
        public
        override
        onlyFactory
        canMint(_optionId)
    {
        emit Transfer(address(0), msg.sender, 0);
        tokenIndex += (_optionId + 1);
    }

    function factoryCanMint(uint256 _optionId)
        public
        view
        override
        returns (bool)
    {
        return
            _optionId < MAX_OPTION_ID &&
            (tokenIndex + _optionId + 1) <= MAX_OPTION_ID;
    }
}

contract FactoryMintableTest is DSTestPlusPlus {
    FactoryMintable test;
    uint256 maxOptionId;

    function setUp() public {
        maxOptionId = 5;
        test = new FactoryMintableImpl(maxOptionId);
    }

    function testFactoryCanMint() public {
        assertTrue(test.factoryCanMint(1));
        assertFalse(test.factoryCanMint(5));
    }

    function testFactoryMint() public {
        vm.prank(test.tokenFactory());
        test.factoryMint(1, address(this));
    }

    function testFactoryMintNotFactory() public {
        vm.expectRevert(abi.encodeWithSignature("NotTokenFactory()"));
        test.factoryMint(1, address(this));
    }

    function testFactoryMintCannotMint() public {
        vm.startPrank(test.tokenFactory());
        vm.expectRevert(abi.encodeWithSignature("FactoryCannotMint()"));
        test.factoryMint(6, address(this));
    }
}
