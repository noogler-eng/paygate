import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import dotenv from "dotenv";
dotenv.config();

const JSON_RPC: string = process.env.JSON_RPC || "";
const API_KEY: string = process.env.API_KEY || "";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    mumbai: {
      url: JSON_RPC,
      accounts: [process.env.PRIVATE_KEY || ""]
    }
  },
  etherscan: {
    apiKey: API_KEY
  },
  sourcify: {
    enabled: true
  }
};

export default config;

// deployed on latest amoy polygon test-chain 