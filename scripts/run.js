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
    "Mewtwo", // Boss Name
    "https://img.pokemondb.net/artwork/mewtwo.jpg", // Boss Image URI
    500, // Boss HP
    30 // Boss attack dmg
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  // We only have 3 characters.
  // an NFT w/ the character at index 2 of our array
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();
  console.log("Minted NFT #1");

  console.log("Done deploying and minting!");

  // Get the value of the first NFT's URI.
  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);

  let players = await gameContract.getAddresses();
  console.log("players", players);

  let checkPlayer = await gameContract.checkIfUserHasNFT(players[0]);
  console.log(checkPlayer);

  let supply = await gameContract.getSupply();
  console.log("supply", supply);
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
