# Factory Contracts
The TokenFactory mint options are recognized as regular ERC721 tokens by OpenSea, which means you can list them using `seaport.createFactorySellOrder()`. The abstract contract `FactoryMintableERC721` automatically creates a factory on deploy and inherits from OpenZeppelin's standard ERC721 contract.

# Listing
An example listing script which reads parameters from an `.env` file and uses `opensea-js` to create sell orders is included in `scripts`.