const { ethers } = require("hardhat");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const owner = deployer;
  const USDT_TOKEN = "";
  console.log(`Network invoked is::: ==>  ${hre.network.name}`);
  console.log(
    `^^^^^^ DEPLOYMENT OF SMART HOTEL BOOKING STARTED ^^^^^^\n\n\n`
  );
  const SmartHotelBooking = await deploy("HotelBooking", {
    from: deployer,
    args: [USDT_TOKEN, owner],
    log: true,
    deterministicDeployment: true,
  });
};

module.exports.tags = ["SmartHotelBooking"];