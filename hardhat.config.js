require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks:{
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts:[process.env.PRIVATE_KEY],
      chainId: 44787
    }
  }
  

};
