// SPDX-License-Identifier: MIT
// Modified 2022 from github.com/divergencetech/ethier
pragma solidity >=0.8.4;

import {OwnerPausable} from "ac/util/OwnerPausable.sol";
import {Strings} from "oz/utils/Strings.sol";
import {FactoryMintable} from "./FactoryMintable.sol";
import {AllowsProxyFromImmutableRegistry} from "ac/util/AllowsProxyFromImmutableRegistry.sol";
import {ReentrancyGuard} from "sm/utils/ReentrancyGuard.sol";
import {ERC721} from "./token/ERC721.sol";

/// @author emo.eth
contract TokenFactory is
    ERC721,
    OwnerPausable,
    AllowsProxyFromImmutableRegistry,
    ReentrancyGuard
{
    using Strings for uint256;
    uint256 public immutable NUM_OPTIONS;

    /// @notice Contract that deployed this factory.
    FactoryMintable public token;

    /// @notice Base URI for constructing tokenURI values for options.
    string public baseOptionURI;

    error NotOwnerOrProxy();
    error InvalidOptionId();

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseOptionURI,
        address _owner,
        uint256 _numOptions,
        address _proxyAddress
    )
        ERC721(_name, _symbol)
        AllowsProxyFromImmutableRegistry(_proxyAddress, true)
    {
        token = FactoryMintable(msg.sender);
        baseOptionURI = _baseOptionURI;
        NUM_OPTIONS = _numOptions;
        // first owner will be the token that deploys the contract
        transferOwnership(_owner);
        createOptionsAndEmitTransfers();
    }

    modifier onlyOwnerOrProxy() {
        if (_msgSender() != owner() && !isProxyOfOwner(owner(), _msgSender())) {
            revert NotOwnerOrProxy();
        }
        _;
    }

    modifier checkValidOptionId(uint256 _optionId) {
        // options are 0-indexed so check should be inclusive
        if (_optionId >= NUM_OPTIONS) {
            revert InvalidOptionId();
        }
        _;
    }

    modifier interactBurnInvalidOptionId(uint256 _optionId) {
        _;
        _burnInvalidOptions();
    }

    /**
    @notice Emits standard ERC721.Transfer events for each option so NFT indexers pick them up.
    Does not need to fire on contract ownership transfer because once the tokens exist, the `ownerOf`
    check will always pass for contract owner.
     */
    function createOptionsAndEmitTransfers() internal {
        // load from storage, read from memory
        uint256 numOptions = NUM_OPTIONS;
        address _owner = owner();
        for (uint256 i = 0; i < numOptions; ) {
            emit Transfer(address(0), _owner, i);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Sets the base URI for constructing tokenURI values for options.
    function setBaseOptionURI(string memory _baseOptionURI) public onlyOwner {
        baseOptionURI = _baseOptionURI;
    }

    /**
    @notice hack: transferFrom is called on sale – this method mints the real token
     */
    function transferFrom(
        address,
        address _to,
        uint256 _optionId
    )
        public
        override
        nonReentrant
        onlyOwnerOrProxy
        whenNotPaused
        interactBurnInvalidOptionId(_optionId)
    {
        token.factoryMint(_optionId, _to);
    }

    function safeTransferFrom(
        address,
        address _to,
        uint256 _optionId
    )
        public
        override
        nonReentrant
        onlyOwnerOrProxy
        whenNotPaused
        interactBurnInvalidOptionId(_optionId)
    {
        token.factoryMint(_optionId, _to);
    }

    /**
    @dev Return true if operator is an approved proxy of Owner
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return isProxyOfOwner(_owner, _operator);
    }

    /**
    @notice Returns owner if _optionId is valid so posted orders pass validation
     */
    function ownerOf(uint256 _optionId) public view override returns (address) {
        return token.factoryCanMint(_optionId) ? owner() : address(0);
    }

    /**
    @notice Returns a URL specifying option metadata, conforming to standard
    ERC721 metadata format.
     */
    function tokenURI(uint256 _optionId)
        public
        view
        override
        returns (string memory)
    {
        return string.concat(baseOptionURI, _optionId.toString());
    }

    ///@notice public facing method for _burnInvalidOptions in case state of tokenContract changes
    function burnInvalidOptions() public onlyOwner {
        _burnInvalidOptions();
    }

    ///@notice "burn" option by sending it to 0 address. This will hide all active listings. Called as part of interactBurnInvalidOptionIds
    function _burnInvalidOptions() internal {
        // load vars from storage, read from memory
        uint256 numOptions = NUM_OPTIONS;
        address _owner = owner();
        FactoryMintable _token = token;
        for (uint256 i; i < numOptions; ) {
            if (!_token.factoryCanMint(i)) {
                emit Transfer(_owner, address(0), i);
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
    @notice emit a transfer event for a "burnt" option back to the owner if factoryCanMint the optionId
    @dev will re-validate listings on OpenSea frontend if an option becomes eligible to mint again
    eg, if max supply is increased
    */
    function restoreOption(uint256 _optionId) external onlyOwner {
        if (token.factoryCanMint(_optionId)) {
            emit Transfer(address(0), owner(), _optionId);
        }
    }

    function supportsFactoryInterface() external pure returns (bool) {
        return true;
    }
}
