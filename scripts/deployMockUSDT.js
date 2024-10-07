const { ethers } = require('hardhat');


async function deployMockUSDT() {
    console.log("^^^^^^^^^^ DEPLOYING MOCK USDT ^^^^^^^^^^^^");
    const mockUSDT = await ethers.deployContract("USDT");

    console.log("Mock USDT deployed at:", mockUSDT.target);
}

deployMockUSDT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });