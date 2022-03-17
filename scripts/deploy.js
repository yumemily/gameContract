const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        ["Bulbasaur", "Cyndaquil", "Mudkip"],       // Names
        [
          "https://img.pokemondb.net/artwork/bulbasaur.jpg", // Images
        "https://img.pokemondb.net/artwork/cyndaquil.jpg",
        "https://img.pokemondb.net/artwork/mudkip.jpg"
      ],

        [300, 150, 115],                    // HP values
        [15, 25, 35],                       // Attack damage values
        ["grass", "fire", "water"],         // Types
        [2, 3, 4], // Crit
        "Mewtwo", // Boss Name
        "https://img.pokemondb.net/artwork/mewtwo.jpg", // Boss Image URI
        500, // Boss HP
        30 // Boss attack dmg
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