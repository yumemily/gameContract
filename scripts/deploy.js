const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Bulbasaur", "Cyndaquil", "Mudkip"], // Names
    [
      "QmXQP9fDEGWGvAh6ZrAmsYks6RsQwjGvERn3JQRoCYxYh6", // Images
      "QmYPhqtm7opR2BFqwn9oJsoQ93Avcm6dF16q2Q36UvcfMG",
      "QmZWnLhzM5DMFxczpxarcWWoX4j4pe3Mx6PtbFpm2LPWqc",
    ],

    [300, 150, 115], // HP values
    [15, 25, 35], // Attack damage values
    ["grass", "fire", "water"], // Types
    [2, 3, 4], // Crit
    "Onix", // Boss Name
    "QmWJ8JDrpPkQzUsX8sakpxyuNjC3CxvKG89GctZodiThGc", // Boss Image URI
    500, // Boss HP
    30, // Boss attack dmg
    "Brock" // Arena Trainer
  );

  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
