const console = require("console");
const { ethers, Wallet, ContractFactory } = require("ethers");
const fs = require("fs");
const process = require("process");
require("dotenv").config();

const DAIToken = "./build/contracts/Dai.json";
const TUSDToken = "./build/contracts/TrueUSD.json";

const DSR = "./build/contracts/DSRMock.json";
const SwapContract = "./build/contracts/SwapContractMock.json";

const DaiFinancialOpportunity =
  "./build/contracts/DaiFinancialOpportunity.json";

let provider, wallet, connectedWallet;

let DaiTokenAddress = "0x7421055f34131d316b7b7e7AaAf01b337C2c8D84"; // ropsten
let TrueUSDAddress = "0x18511bAB4f5096D030aFFfE846AB1f78Bb7E7C48"; // ropsten

let DSRAddress = "0x1e25013944A529D676FE9C5e77Bc39A820b584c9";
let SwapContractAddress = "0x5936e17E47bC01AB223c6258eF5A97A7D254B424";

let DaiFinancialOpportunityAddress = "";

if (process.env.NETWORK == "mainnet") {
  provider = ethers.getDefaultProvider("homestead");
} else if (process.env.NETWORK == "ropsten") {
  provider = ethers.getDefaultProvider("ropsten");
}

wallet = Wallet.fromMnemonic(process.env.MNEMONIC);
connectedWallet = wallet.connect(provider);

const unpackArtifact = (artifactPath) => {
  let contractData = JSON.parse(fs.readFileSync(artifactPath));

  const contractBytecode = contractData["bytecode"];
  const contractABI = contractData["abi"];
  const constructorArgs = contractABI.filter((itm) => {
    return itm.type == "constructor";
  });

  let constructorStr;
  if (constructorArgs.length < 1) {
    constructorStr = " -- No constructor arguments -- ";
  } else {
    constructorJSON = constructorArgs[0].inputs;
    constructorStr = JSON.stringify(
      constructorJSON.map((c) => {
        return {
          name: c.name,
          type: c.type,
        };
      })
    );
  }

  return {
    abi: contractABI,
    bytecode: contractBytecode,
    contractName: contractData.contractName,
    constructor: constructorStr,
  };
};

const deployContract = async (
  contractABI,
  contractBytecode,
  wallet,
  provider,
  args = []
) => {
  const factory = new ContractFactory(
    contractABI,
    contractBytecode,
    wallet.connect(provider)
  );
  return await factory.deploy(...args);
};

const deploy = async (artifactPath, args) => {
  try {
    let tokenUnpacked = unpackArtifact(artifactPath);
    console.log(
      `${tokenUnpacked.contractName} \n Constructor: ${tokenUnpacked.constructor}`
    );
    const token = await deployContract(
      tokenUnpacked.abi,
      tokenUnpacked.bytecode,
      wallet,
      provider,
      args
    );
    console.log(`⌛ Deploying ${tokenUnpacked.contractName}...`);

    await connectedWallet.provider.waitForTransaction(
      token.deployTransaction.hash
    );
    console.log(
      `✅ Deployed ${tokenUnpacked.contractName} to ${token.address}`
    );
  } catch (err) {
    console.log("deploy ======>", err);
  }
};

// From here, all the args are to be determined.
if (!DaiTokenAddress) {
  deploy(DAIToken);
  return;
}

if (!TrueUSDAddress) {
  deploy(TUSDToken);
  return;
}

if (!DSRAddress) {
  deploy(DSR, [DaiTokenAddress]);
  return;
}

if (!SwapContractAddress) {
  deploy(SwapContract, [DaiTokenAddress, TrueUSDAddress]);
  return;
}

if (!DaiFinancialOpportunityAddress) {
  deploy(DaiFinancialOpportunity, [
    SwapContractAddress,
    DSRAddress,
    TrueUSDAddress,
    DaiTokenAddress,
  ]);
  return;
}
