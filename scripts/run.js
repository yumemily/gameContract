const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    const gameContract = await gameContractFactory.deploy(
        ["Bulbasaur", "Cyndaquil", "Mudkip"],       // Names
        ["https://archives.bulbagarden.net/media/upload/thumb/2/21/001Bulbasaur.png/500px-001Bulbasaur.png", // Images
        "https://archives.bulbagarden.net/media/upload/thumb/9/9b/155Cyndaquil.png/500px-155Cyndaquil.png",
        "https://archives.bulbagarden.net/media/upload/thumb/6/60/258Mudkip.png/500px-258Mudkip.png"],

        [300, 150, 115],                    // HP values
        [15, 25, 35],                       // Attack damage values
        ["grass", "fire", "water"],         // Types
        [2, 3, 4] //Crit
      );
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    // We only have 3 characters.
    // an NFT w/ the character at index 2 of our array
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();
    console.log("Minted NFT #1");

    txn = await gameContract.mintCharacterNFT(1)
    await txn.wait();
    console.log("Minted NFT #2");

    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    console.log("Minted NFT #3");

    console.log("Done deploying and minting!")


    // Get the value of the first NFT's URI.
    let returnedTokenUri = await gameContract.tokenURI(1);
    console.log("Token URI:", returnedTokenUri)
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