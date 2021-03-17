require("dotenv").config();

var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
  api_keys: {
    etherscan: process.env.ETHERSCAN_APIKEY,
  },
  networks: {
    mainnet: {
      provider: function () {
        return new HDWalletProvider(
          `${process.env.MNEMONIC}`,
          `https://mainnet.infura.io/v3/${process.env.INFURA_APIKEY}`
        );
      },
      network_id: 1,
    },
    ropsten: {
      provider: function () {
        return new HDWalletProvider(
          `${process.env.MNEMONIC}`,
          `https://ropsten.infura.io/v3/${process.env.INFURA_APIKEY}`
        );
      },
      network_id: 3,
    },
  },
  mocha: {
    timeout: 100000,
  },
  compilers: {
    solc: {
      version: "0.6.2",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
  plugins: ["truffle-plugin-verify"],
};
