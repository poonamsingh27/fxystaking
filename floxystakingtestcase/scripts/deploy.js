const { ethers } = require("hardhat");

async function deployFXYStakingContract() {
  // Replace these addresses and values with your actual values
  const fxyTokenAddress = "0x3add0d140057303aeaa689c867ca2ea3a7f844ad";
  const feeReceiverAddress = "0xcDEEd618B32446e0dF0BD0F3a58CB41B262C13e7";
  const minFXY = 100;
  const preMatureFXYPenalty = 10;
  const baseAPY = 2;
  const stakeDurationInDays = [30, 60, 90, 360];
  const multiplier = [1, 2, 3, 4];

  // Get the contract factories
  const FXYStaking = await ethers.getContractFactory("FXYStaking");
  //const ERC20Burnable = await ethers.getContractFactory("ERC20Burnable"); // Make sure you have ERC20Burnable contract

  // Deploy the ERC20Burnable contract
  //const fxyToken = await ERC20Burnable.attach(fxyTokenAddress);

  // Deploy the FXYStaking contract
  const fxyStaking = await FXYStaking.deploy(
    fxyTokenAddress,
    feeReceiverAddress,
    minFXY,
    preMatureFXYPenalty,
    baseAPY,
    stakeDurationInDays,
    multiplier
  );

  await fxyStaking.deployed();

  console.log("FXYStaking contract deployed to:", fxyStaking.address);
}

deployFXYStakingContract();