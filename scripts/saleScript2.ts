import * as dotenv from "dotenv";
import { OpenSeaPort, Network } from "opensea-js";
import * as fs from "fs";
import { exit } from "process";
dotenv.config();

const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonic = fs.readFileSync(".mnemonic").toString().trim();
const ETH_RPC_URL = process.env.ETH_RPC_URL;
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const FACTORY_CONTRACT_OWNER_ADDRESS =
    process.env.FACTORY_CONTRACT_OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const OPENSEA_API_KEY = process.env.OPENSEA_API_KEY;

if (!mnemonic || !ETH_RPC_URL || !NETWORK || !FACTORY_CONTRACT_OWNER_ADDRESS) {
    console.error(
        "Please set a mnemonic, Alchemy/Infura key, owner, network, API key, nft contract, and factory contract address."
    );
}

if (!FACTORY_CONTRACT_ADDRESS) {
    console.error("Please specify a factory contract address.");
}

const provider = new HDWalletProvider(mnemonic, ETH_RPC_URL, 0);
console.log("Connected:", provider.getAddress());

const seaport = new OpenSeaPort(
    provider,
    {
        networkName: Network.Main,
        apiKey: OPENSEA_API_KEY,
    },
    (arg) => console.log(arg)
);

async function main() {
    // listing activates in one minute
    // const listingTime = Math.round(Date.now() / 1000) + 60;
    const listingTime = Math.floor(new Date(2022, 3, 11, 9).getTime() / 1000);

    // expires in 24 hours
    const expirationTime = listingTime + 60 * 60 * 24 * 30;

    const price = 0.05;
    const optionAmount = [1, 2, 5, 10, 25, 50, 73, 91];

    for (let i = 0; i < optionAmount.length; ++i) {
        console.log(`Create factory sell orders for optionId: ${i}`);

        const numberOfOrders = Math.floor(5_000 / optionAmount[i]);
        const startAmount = Number((optionAmount[i] * price).toFixed(2));

        console.log(numberOfOrders, "@", startAmount);

        // const fixedSellOrders = await seaport.createFactorySellOrders({
        //   assets: [
        //     {
        //       tokenId: String(i),
        //       tokenAddress: FACTORY_CONTRACT_ADDRESS,
        //     },
        //   ],
        //   accountAddress: FACTORY_CONTRACT_OWNER_ADDRESS,
        //   startAmount: startAmount,
        //   listingTime: listingTime,
        //   expirationTime: expirationTime,
        //   numberOfOrders: numberOfOrders,
        // });
    }

    const options = [
        [1, 0, 5000, 0.05],
        [2, 0, 2500, 0.1],
        [5, 0, 1000, 0.25],
        [10, 0, 500, 0.5],
        [25, 0, 200, 1.25],
        [50, 0, 100, 2.5],
        [73, 0, 68, 3.65],
        [91, 0, 54, 4.55],
    ];
    const optionId = 7;
    const sellOption = options[optionId];

    const sellOrder = true;
    if (sellOrder) {
        const minted = sellOption[1];
        const remaining = sellOption[2] - minted;
        for (let index = 1; index <= remaining; index++) {
            const fixedSellOrders = await seaport.createFactorySellOrders({
                assets: [
                    {
                        tokenId: String(optionId),
                        tokenAddress: FACTORY_CONTRACT_ADDRESS,
                    },
                ],
                accountAddress: FACTORY_CONTRACT_OWNER_ADDRESS,
                startAmount: sellOption[3],
                listingTime: listingTime,
                expirationTime: expirationTime,
                numberOfOrders: 1,
            });

            console.log("optionId:", optionId);
            console.log(
                "Minted:",
                index,
                `(${Math.floor(((index + minted) / (remaining + minted)) * 100)}%)`
            );
        }
    }

    exit();
}

main();