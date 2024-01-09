const { expect } = require("chai");

describe("FXYStaking Contract", function () {
  let fxyStaking;
  let owner;
  let user = '0x5C2B4bBA8c7C7A9b2D62943e1e7fcB1CfC0681D5';

  const fxyTokenAddress = "0x7d061E6d0f1F2Af4E129942ad97fedc792Fb121C";
  const feeReceiverAddress = "0x48a5dC476EF95F87bC0A9cCe443186AB1a9e2b36";
  const minFXY = 10;
  const preMatureFXYPenalty = 10;
  const baseAPY = 5;
  const stakeDurationInDays = [ 30,90,180];
  const multiplier = [1,2,3];

  beforeEach(async function () {
    // Deploy FXYStaking contract
    const FXYStaking = await ethers.getContractFactory("FXYStaking");
    fxyStaking = await FXYStaking.deploy(
      fxyTokenAddress,
      feeReceiverAddress,
      minFXY,
      preMatureFXYPenalty,
      baseAPY,
      stakeDurationInDays,
      multiplier
    );

    await fxyStaking.deployed();

    // Get owner and user accounts
    [owner, user] = await ethers.getSigners();
  });

  it("should stake", async function () { try {
     // Stake FXY tokens
    const stakeamount = '100000000000000000000';
    const stakeDurationInseconds = '2592000'
    await expect(fxyStaking.connect(user).stake(stakeamount, stakeDurationInseconds));

  } catch (error) {
    console.log("Revert Reason:", error.reason);
}
   });

  it("should update parameters correctly", async function () {
    // Update preMatureFXYPenalty
    await fxyStaking.connect(owner).updatePreMaturePenalty(10);
    const updatedPenalty = await fxyStaking.preMatureFXYPenalty();
    expect(updatedPenalty).to.equal(10);

  //   // Update baseAPY
    await fxyStaking.connect(owner).updateAPY(5);
    const updatedAPY = await fxyStaking.baseAPY();
    expect(updatedAPY).to.equal(5);

  //   // Update minFXY
    await fxyStaking.connect(owner).updateMinMLD(10);
    const updatedMinFXY = await fxyStaking.minFXY();
    expect(updatedMinFXY).to.equal(10);
   });

   it("should withdraw correctly", async function () { try {

    // Withdraw from the first deposit (index 0)
    const index = 2;
    await expect(fxyStaking.connect(user).withdraw(index));

   }catch (error) {
      console.log("Revert Reason:", error.reason);
      // Add more logging or assertions based on the error details
    }
  });


});