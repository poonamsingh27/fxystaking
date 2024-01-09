// require("@nomicfoundation/hardhat-toolbox");

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   solidity: "0.8.19",
// };

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

// require("@nomicfoundation/hardhat-toolbox");

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and replace "KEY" with it
const INFURA_API_KEY = "f77800ff05bf49d1b12787b2e7c24b6c";

// Replace this private key with your Sepolia account private key
// To export your private key from Coinbase Wallet, go to
// Settings > Developer Settings > Show private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const mumbai_PRIVATE_KEY = "95862be5d0de2e26ab733e6fd8796af7ad55df12ec0b2123865cf9b2058b9afb";

module.exports = {
  solidity: "0.8.20",
  networks: {
    Mumbai: {
      url: `https://rpc-mumbai.maticvigil.com`,
      accounts: [mumbai_PRIVATE_KEY]
    }
  }
};;
