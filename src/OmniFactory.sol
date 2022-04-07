// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.12;

// import {OwnerPausable} from "ac/util/OwnerPausable.sol";
// import {Strings} from "oz/utils/Strings.sol";
// import {ERC721} from "./token/ERC721.sol";
// import {IFactoryMintable} from "./IFactoryMintable.sol";
// import {AllowsProxyFromConfigurableRegistry} from "ac/util/AllowsProxyFromConfigurableRegistry.sol";
// import {OmniTokenFactory} from "./OmniTokenFactory.sol";
// import {AllowsProxyFromConfigurableRegistry} from "ac/util/AllowsProxyFromConfigurableRegistry.sol";

// abstract contract OmniFactoryMintableERC721 is
//     OmniTokenFactory,
//     IFactoryMintable,
//     ERC721
// {
//     using Strings for uint256;
//     string public baseURI;

//     constructor(
//         string memory _name,
//         string memory _symbol,
//         string memory _baseUri,
//         address _proxyAddress,
//         uint256 _numOptions
//     ) ERC721(_name, _symbol) OmniTokenFactory(_numOptions) {
//         baseURI = _baseUri;
//     }

//     function ownerOf(uint256 _tokenId)
//         public
//         view
//         override(ERC721, OmniTokenFactory)
//         returns (address)
//     {
//         if (isFactoryOptionId(_tokenId)) {
//             return factoryCanMint(_tokenId) ? owner() : address(0);
//         }
//         return super.ownerOf(_tokenId);
//     }

//     function transferFrom(
//         address _from,
//         address _to,
//         uint256 _tokenId
//     ) public virtual override(ERC721, OmniTokenFactory) {
//         if (isFactoryOptionId(_tokenId)) {
//             factoryMint(_to, _tokenId);
//         } else {
//             super.transferFrom(_from, _to, _tokenId);
//         }
//     }

//     function safeTransferFrom(
//         address _from,
//         address _to,
//         uint256 _tokenId
//     ) public virtual override(ERC721, OmniTokenFactory) {
//         if (isFactoryOptionId(_tokenId)) {
//             factoryMint(_to, _tokenId);
//         } else {
//             super.transferFrom(_from, _to, _tokenId);
//         }
//     }

//     function factoryMint(address _to, uint256 _tokenId)
//         public
//         virtual
//         onlyOwnerOrProxy
//     {
//         if (isFactoryOptionId(_tokenId)) {
//             if (factoryCanMint(_tokenId)) {
//                 _mint(_to, _tokenId);
//             }
//         }
//     }

//     function factoryCanMint(uint256 _tokenId)
//         public
//         view
//         virtual
//         returns (bool);

//     function isFactoryOptionId(uint256 _tokenId) public view returns (bool) {
//         return true;
//     }

//     function tokenURI(uint256 _tokenId)
//         public
//         view
//         virtual
//         override(ERC721, OmniTokenFactory)
//         returns (string memory)
//     {
//         return string.concat(baseURI, _tokenId.toString());
//     }

//     /**
//     @dev Return true if operator is an approved proxy of Owner
//      */
//     function isApprovedForAll(address _owner, address _operator)
//         public
//         view
//         override(ERC721, OmniTokenFactory)
//         returns (bool)
//     {
//         return
//             // should resolve to ERC721 method as it is last in inheritance
//             super.isApprovedForAll(_owner, _operator) ||
//             isApprovedForProxy(_owner, _operator);
//     }
// }
