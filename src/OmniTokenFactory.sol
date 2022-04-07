// // SPDX-License-Identifier: MIT
// // Modified 2022 from github.com/divergencetech/ethier
// pragma solidity ^0.8.12;

// import {OwnerPausable} from "ac/util/OwnerPausable.sol";
// import {Strings} from "oz/utils/Strings.sol";
// import {FactoryMintable} from "./FactoryMintable.sol";
// import {AllowsProxyFromConfigurableRegistry} from "ac/util/AllowsProxyFromConfigurableRegistry.sol";
// import {ReentrancyGuard} from "sm/utils/ReentrancyGuard.sol";
// import {ITokenFactory} from "./ITokenFactory.sol";
// import {IAllowsProxy} from "ac/util/IAllowsProxy.sol";
// import {Ownable} from "oz/access/Ownable.sol";

// /// @author emo.eth
// abstract contract OmniTokenFactory is ITokenFactory, IAllowsProxy, Ownable {
//     using Strings for uint256;
//     uint256 public immutable NUM_OPTIONS;

//     /**
//     @notice Standard ERC721 Transfer event, used to trigger indexing of tokens.
//      */
//     event Transfer(
//         address indexed from,
//         address indexed to,
//         uint256 indexed tokenId
//     );

//     error NotOwnerOrProxy();
//     error InvalidOptionId();

//     constructor(uint256 _numOptions) {
//         NUM_OPTIONS = _numOptions;
//         createOptionsAndEmitTransfers();
//     }

//     modifier onlyOwnerOrProxy() {
//         if (
//             _msgSender() != owner() &&
//             !isApprovedForProxy(owner(), _msgSender())
//         ) {
//             revert NotOwnerOrProxy();
//         }
//         _;
//     }

//     modifier checkValidOptionId(uint256 _optionId) {
//         // options are 0-indexed so check should be inclusive
//         if (_optionId >= NUM_OPTIONS) {
//             revert InvalidOptionId();
//         }
//         _;
//     }

//     modifier interactBurnInvalidOptionId(uint256 _optionId) {
//         _;
//         _burnInvalidOptions();
//     }

//     /**
//     @notice Emits standard ERC721.Transfer events for each option so NFT indexers pick them up.
//     Does not need to fire on contract ownership transfer because once the tokens exist, the `ownerOf`
//     check will always pass for contract owner.
//      */
//     function createOptionsAndEmitTransfers() internal {
//         for (uint256 i = 0; i < NUM_OPTIONS; i++) {
//             emit Transfer(address(0), owner(), i);
//         }
//     }

//     /**
//     @notice hack: transferFrom is called on sale – this method mints the real token
//      */
//     function transferFrom(
//         address,
//         address _to,
//         uint256 _optionId
//     ) public virtual;

//     function safeTransferFrom(
//         address,
//         address _to,
//         uint256 _optionId
//     ) public virtual;

//     /**
//     @dev Return true if operator is an approved proxy of Owner
//      */
//     function isApprovedForAll(address _owner, address _operator)
//         public
//         view
//         virtual
//         returns (bool);

//     function isApprovedForProxy(address _owner, address _operator)
//         public
//         view
//         virtual
//         returns (bool);

//     /**
//     @notice Returns owner if _optionId is valid so posted orders pass validation
//      */
//     function ownerOf(uint256 _optionId) public view virtual returns (address);

//     /**
//     @notice Returns a URL specifying option metadata, conforming to standard
//     ERC721 metadata format.
//      */
//     function tokenURI(uint256 _optionId)
//         public
//         view
//         virtual
//         returns (string memory);

//     ///@notice public facing method for _burnInvalidOptions in case state of tokenContract changes
//     function burnInvalidOptions() public virtual;

//     function _burnInvalidOptions() internal virtual;

//     /**
//     @notice emit a transfer event for a "burnt" option back to the owner if factoryCanMint the optionId
//     @dev will re-validate listings on OpenSea frontend if an option becomes eligible to mint again
//     eg, if max supply is increased
//     */
//     function restoreOption(uint256 _optionId) external virtual;
// }
