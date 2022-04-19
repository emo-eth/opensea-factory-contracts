// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import {DSTestPlusPlus} from "ac/test/helpers/DSTestPlusPlus.sol";
import {stdError, Vm} from "forge-std/Test.sol";
import {FactoryMintable} from "../FactoryMintable.sol";
import {TokenFactory} from "../TokenFactory.sol";
import {ProxyRegistry, OwnableDelegateProxy} from "../utils/ProxyRegistry.sol";
import {ExampleFactoryMintableERC721} from "../examples/ExampleFactoryMintableERC721.sol";

contract ProxyRegistryImpl is ProxyRegistry {
    function registerProxy(address _owner, address _operator) public {
        proxies[_owner] = OwnableDelegateProxy(_operator);
    }
}

contract TokenFactoryTest is DSTestPlusPlus {
    // StdStorage internal stdstore;
    // using stdStorage for StdStorage;
    ExampleFactoryMintableERC721 mintable;
    TokenFactory test;
    uint256 maxSupply = 5;
    uint16 maxOptionId = 5;
    ProxyRegistryImpl registry;
    bytes32 LIVE_OPTIONS_SLOT = bytes32(uint256(8));

    function setUp() public {
        registry = new ProxyRegistryImpl();
        emit log_named_address("sender", msg.sender);
        mintable = new ExampleFactoryMintableERC721(
            5,
            address(registry),
            maxOptionId
        );

        test = TokenFactory(mintable.tokenFactory());
        registry.registerProxy(address(this), address(1234));
    }

    function testConstructorInitializesValues() public {
        assertEq(test.name(), "test Factory");
        assertEq(test.symbol(), "TESTFACTORY");
        assertEq(test.tokenURI(0), "ipfs://option0");
        assertEq(test.owner(), address(this));
        assertEq(test.proxyRegistryAddress(), address(registry));
        assertEq(test.NUM_OPTIONS(), 5);
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function testEmitTransfers() public {
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(0), address(this), 1);
        test.restoreOption(1);
    }

    function testSetBaseOptionURI() public {
        test.setBaseOptionURI("hello");
        assertEq("hello", test.baseOptionURI());
    }

    function testSetBaseOptionURIOnlyOwner() public {
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        test.setBaseOptionURI("hello");
    }

    function testTransferFromMints() public {
        test.transferFrom(address(this), address(this), 1);
        assertEq(address(this), mintable.ownerOf(0));
    }

    function testTransferFromOnlyOwnerOrProxy() public {
        test.transferFrom(address(this), address(this), 1);
        vm.prank(address(1234));
        test.transferFrom(address(this), address(this), 1);
        vm.startPrank(address(5678));
        vm.expectRevert(errorSig("NotOwnerOrProxy()"));
        test.transferFrom(address(this), address(this), 1);
    }

    function testTransferFromInteractBurnInvalidOptionId() public {
        // for (uint256 i; i < 12; i++) {
        //     emit log_named_bytes32("var", vm.load(address(test), bytes32(i)));
        // }

        assertEq(
            vm.load(address(test), LIVE_OPTIONS_SLOT),
            bytes32(uint256(31))
        );
        assertTrue(mintable.factoryCanMint(2));
        assertTrue(mintable.factoryCanMint(3));
        assertTrue(mintable.factoryCanMint(4));

        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 0); // 0 is burned because factory always marks it as invalid, fix?
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 2); // should "burn" options 0, 2, 3, 4
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 3);
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 4);

        test.transferFrom(address(this), address(this), 4);
        assertEq(
            vm.load(address(test), LIVE_OPTIONS_SLOT),
            bytes32(uint256(2)) // mint 1 option is off by 1
        );
        assertFalse(mintable.factoryCanMint(2));
        assertFalse(mintable.factoryCanMint(3));
        assertFalse(mintable.factoryCanMint(4));
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 1);
        test.transferFrom(address(this), address(this), 1);
        assertEq(
            vm.load(address(test), LIVE_OPTIONS_SLOT),
            bytes32(uint256(0))
        );
        assertFalse(mintable.factoryCanMint(1));
    }

    function testFailTransferFromInteractBurnInvalidOptionIdOnlyBurnsUnburnedIds()
        public
    {
        assertTrue(mintable.factoryCanMint(2));
        assertTrue(mintable.factoryCanMint(3));
        assertTrue(mintable.factoryCanMint(4));
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 4);
        emit Transfer(address(this), address(0), 3);
        emit Transfer(address(this), address(0), 2); // should "burn" options 2, 3, 4
        test.transferFrom(address(this), address(this), 4);
        assertFalse(mintable.factoryCanMint(2));
        assertFalse(mintable.factoryCanMint(3));
        assertFalse(mintable.factoryCanMint(4));
        // test we don't re-burn options
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 4);
        test.transferFrom(address(this), address(this), 1);
    }

    function testSafeTransferFromMints() public {
        test.safeTransferFrom(address(this), address(this), 1);
        assertEq(address(this), mintable.ownerOf(0));
    }

    function testSafeTransferFromOnlyOwnerOrProxy() public {
        test.safeTransferFrom(address(this), address(this), 1);
        vm.prank(address(1234));
        test.safeTransferFrom(address(this), address(this), 1);
        vm.startPrank(address(5678));
        vm.expectRevert(errorSig("NotOwnerOrProxy()"));
        test.safeTransferFrom(address(this), address(this), 1);
    }

    // function testSafeTransferFromWhenNotPaused() public {
    //     test.pause();
    //     vm.expectRevert("Pausable: paused");
    //     test.safeTransferFrom(address(this), address(this), 1);
    // }

    function testSafeTransferFromInteractBurnInvalidOptionId() public {
        assertTrue(mintable.factoryCanMint(2));
        assertTrue(mintable.factoryCanMint(3));
        assertTrue(mintable.factoryCanMint(4));
        vm.expectEmit(true, true, true, false);
        emit Transfer(address(this), address(0), 4);
        emit Transfer(address(this), address(0), 3);
        emit Transfer(address(this), address(0), 2);

        // should "burn" options 2, 3, 4
        test.transferFrom(address(this), address(this), 4);
        assertFalse(mintable.factoryCanMint(2));
        assertFalse(mintable.factoryCanMint(3));
        assertFalse(mintable.factoryCanMint(4));
    }

    function testIsApprovedForAll() public {
        assertTrue(test.isApprovedForAll(address(this), address(1234)));
        assertFalse(test.isApprovedForAll(address(this), address(5678)));
        test.transferOwnership(address(5678));
        assertFalse(test.isApprovedForAll(address(5678), address(1234)));
    }

    function testOwnerOf() public {
        assertEq(address(this), test.ownerOf(4));
        test.transferFrom(address(this), address(this), 3);
        assertEq(address(0), test.ownerOf(4));
        assertEq(address(this), test.ownerOf(1));
        test.transferOwnership(address(1234));
        assertEq(address(1234), test.ownerOf(1));
    }

    function testTokenURI() public {
        assertEq("ipfs://option1", test.tokenURI(1));
        test.setBaseOptionURI("hello");
        assertEq("hello1", test.tokenURI(1));
    }

    function testBurnInvalidOption() public {
        assertEq(address(this), test.ownerOf(4));
        test.burnInvalidOptions();
    }

    function testBurnInvalidOptionOnlyOwner() public {
        test.transferOwnership(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        test.burnInvalidOptions();
    }

    function testRestoreOption() public {
        test.transferFrom(address(this), address(this), 5);
        assertEq(address(0), test.ownerOf(10000));
        mintable.setMaxSupply(11111);
        test.restoreOption(1);
        assertEq(address(this), test.ownerOf(1));
        assertEq(
            vm.load(address(test), LIVE_OPTIONS_SLOT),
            bytes32(uint256(2))
        );

        vm.expectRevert(TokenFactory.InvalidOptionId.selector);
        test.restoreOption(42);
    }

    function testRestoreMintableOptions() public {
        // todo: this should probably fail
        test.transferFrom(address(this), address(this), 5);
        assertEq(address(0), test.ownerOf(10000));
        mintable.setMaxSupply(11111);
        test.restoreMintableOptions();
        assertEq(address(this), test.ownerOf(1));
        assertEq(address(this), test.ownerOf(2));
        assertEq(address(this), test.ownerOf(3));
        assertEq(address(this), test.ownerOf(4));

        assertEq(
            vm.load(address(test), LIVE_OPTIONS_SLOT),
            bytes32(uint256(30))
        );
    }

    function testRestoreOptionOnlyOwner() public {
        test.transferFrom(address(this), address(this), 5);
        assertEq(address(0), test.ownerOf(10000));
        mintable.setMaxSupply(11111);
        test.transferOwnership(address(1234));
        vm.expectRevert("Ownable: caller is not the owner");
        test.restoreOption(10000);
    }
}
