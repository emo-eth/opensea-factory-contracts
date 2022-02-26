import * as dotenv from 'dotenv';
import { OpenSeaPort, Network } from 'opensea-js';
dotenv.config();

const HDWalletProvider = require('@truffle/hdwallet-provider');

const MNEMONIC = process.env.MNEMONIC;
const ETH_RPC_URL = process.env.ETH_RPC_URL
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const FACTORY_CONTRACT_OWNER_ADDRESS =
    process.env.FACTORY_CONTRACT_OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const NUM_ORDERS = +process.env.NUM_ORDERS
const FACTORY_OPTION_ID = process.env.FACTORY_OPTION_ID;
const OPENSEA_API_KEY = process.env.OPENSEA_API_KEY;

if (!MNEMONIC || !ETH_RPC_URL || !NETWORK || !FACTORY_CONTRACT_OWNER_ADDRESS) {
    console.error(
        "Please set a mnemonic, Alchemy/Infura key, owner, network, API key, nft contract, and factory contract address."
    );
}

if (!FACTORY_CONTRACT_ADDRESS) {
    console.error("Please specify a factory contract address.");
}


const provider = new HDWalletProvider(MNEMONIC, process.env.ETH_RPC_URL);
const seaport = new OpenSeaPort(
    provider,
    {
        networkName:
            NETWORK === "mainnet" || NETWORK === "live"
                ? Network.Main
                : Network.Rinkeby,
        apiKey: OPENSEA_API_KEY,
    },
    (arg) => console.log(arg)
);

async function main() {
    console.log("Creating Invite List sale...");

    // listing activates in one minute
    const listingTime = Math.round(Date.now() / 1000) + 60;
    // expires in 24 hours
    const expirationTime = listingTime + 60 * 60 * 24;

    const price = 0.1;
    for (let i = 0; i < NUM_ORDERS; i += 10) {
        const orderArgs = {
            assets: [
                {
                    tokenId: FACTORY_OPTION_ID,
                    tokenAddress: FACTORY_CONTRACT_ADDRESS,
                },
            ],
            accountAddress: FACTORY_CONTRACT_OWNER_ADDRESS,
            startAmount: price,
            listingTime: listingTime,
            expirationTime: expirationTime,
            numberOfOrders: 10,
        };


    }
}

main();
