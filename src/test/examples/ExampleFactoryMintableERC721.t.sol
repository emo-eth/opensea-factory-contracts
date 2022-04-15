// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "ac/test/helpers/DSTestPlusPlus.sol";
import {ExampleFactoryMintableERC721} from "../../examples/ExampleFactoryMintableERC721.sol";
import {TokenFactory} from "../../TokenFactory.sol";

contract ExampleFactoryMintableERC721Test is DSTestPlusPlus {
    ExampleFactoryMintableERC721 test;

    function setUp() public {
        test = new ExampleFactoryMintableERC721(10000, address(1), 10000);
    }

    function testConstructorInitializesValues() public {
        assertEq("test", test.name());
        assertEq("TEST", test.symbol());
        assertEq("ipfs://test", test.baseURI());
        assertEq(address(1), test.proxyRegistryAddress());
        TokenFactory factory = TokenFactory(test.tokenFactory());
        assertEq("ipfs://option", factory.baseOptionURI());
        assertEq(10000, factory.NUM_OPTIONS());
    }

    function testFactoryMint() public {
        vm.prank(test.tokenFactory());
        test.factoryMint(1, address(this));
        assertEq(test.ownerOf(0), address(this));
    }

    function testFactoryMintOnlyFactory() public {
        vm.expectRevert(errorSig("NotTokenFactory()"));
        test.factoryMint(1, address(this));
    }

    function testFactoryMintCanMint() public {
        vm.startPrank(test.tokenFactory());
        vm.expectRevert(errorSig("FactoryCannotMint()"));
        test.factoryMint(0, address(this));
        vm.expectRevert(errorSig("FactoryCannotMint()"));
        test.factoryMint(1000000, address(this));
        test.factoryMint(5, address(this));
        vm.expectRevert(errorSig("FactoryCannotMint()"));
        test.factoryMint(9999, address(this));
    }

    function testFactoryCanMint() public {
        assertTrue(test.factoryCanMint(1));
        assertFalse(test.factoryCanMint(10000000));
        assertFalse(test.factoryCanMint(0));
    }

    function testSetMaxSupply() public {
        assertEq(10000, test.maxSupply());
        test.setMaxSupply(10001);
        assertEq(10001, test.maxSupply());
    }

    function testSetMaxSupplyMustBeGreater() public {
        vm.expectRevert(errorSig("NewMaxSupplyMustBeGreater()"));
        test.setMaxSupply(1);
    }

    function testSetMaxSupplyOnlyOwner() public {
        test.transferOwnership(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        test.setMaxSupply(10001);
    }
}
