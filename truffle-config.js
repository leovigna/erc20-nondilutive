if (process.env.NODE_ENV !== 'production') {
    require('dotenv').config();
}

const path = require("path");
const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    //contracts_build_directory: path.join(__dirname, "app/src/contracts"),
    networks: {
        development: {
            gas: 6721975,
            gasPrice: 0,
            provider: function () {
                return new HDWalletProvider(process.env.LOCAL_HD_WALLET_MNEMONIC, process.env.LOCAL_RPC);
            },
            networkId: '5777',
        },
        ropsten: {
            gas: 6721975,
            gasPrice: 5000000000,
            provider: function () {
                return new HDWalletProvider(process.env.ROPSTEN_HD_WALLET_MNEMONIC, process.env.ROPSTEN_RPC);
            },
            network_id: '3',
        },
        mainnet: {
            gas: process.env.MAINNET_GASLIMIT || 1000000,
            gasPrice: process.env.MAINNET_GASPRICE || 5000000000,
            provider: function () {
                return new HDWalletProvider(process.env.MAINNET_HD_WALLET_MNEMONIC, process.env.MAINNET_RPC);
            },
            network_id: '1',
        }
    },
    compilers: {
        solc: {
            version: "^0.5.0", // A version or constraint - Ex. "^0.5.0"
            parser: "solcjs",  // Leverages solc-js purely for speedy parsing
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200   // Optimize for how many times you intend to run the code
                },
                evmVersion: "petersburg"
            }
        }
    }
}