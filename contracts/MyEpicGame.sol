// SPDX-License-Identifier: UNLICENSED

// the version of the solidity compiler we want contract to use
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// Our contract inherits from ERC721, which is the standard NFT contract
contract MyEpicGame is ERC721 {
    // We'll hold our character's attributes in a struct. Feel free to add
    // whatever you'd like as an attribute! (ex. defense, crit chance, etc).
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
        string characterType;
        uint256 crit;
    }

    // The tokenId is the NFTs unique identifier, it's just a number that goes
    // 0, 1, 2, 3, etc.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // A lil array to help us hold the default data for our characters.
    // This will be helpful when we mint new characters and need to know
    // things like their HP, AD, etc.
    CharacterAttributes[] defaultCharacters;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;

    // fire event when we finish minting an NFt for the user
    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );
    event AttackComplete(
        address sender,
        uint256 newBossHp,
        uint256 newPlayerHp
    );

    // Hold boss's attributes in a struct
    struct BigBoss {
        string name;
        string imageURI;
        string trainer;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    address payable[] public players;

    // Data passed in to the contract when it's first created initializing the characters.
    // We're going to actually pass these values in from run.js.
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string[] memory characterTypes,
        uint256[] memory characterCrit,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage,
        string memory bossTrainer
    ) ERC721("Pokemon", "POKE") {
        // Initialize the boss. Save it to our global "bigBoss" state variable.
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage,
            trainer: bossTrainer
        });

        console.log(
            "Done initializing boss %s w/ hp %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

        // Loop through all the characters, and save their values in our contract so
        // we can use them later when we mint our NFTs.
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i],
                    characterType: characterTypes[i],
                    crit: characterCrit[i]
                })
            );

            // Hardhat's use of console.log() allows up to 4 parameters that are the type uint, string, bool address
            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s, img %s",
                c.name,
                c.hp,
                c.imageURI
            );
            console.log("%s dmg, type %s", c.attackDamage, c.characterType);
        }
        // I increment _tokenIds here in the constructor so that my first NFT has an ID of 1.
        _tokenIds.increment();
    }

    // Get functions

    function getAddresses() public view returns (address payable[] memory) {
        return players;
    }

    function getSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    function checkIfUserHasNFT(address player)
        public
        view
        returns (CharacterAttributes memory)
    {
        // get the tokenId of hthe user's character NFT
        uint256 userNftTokenID = nftHolders[player];
        // if the user has a tokenId in the map, return the character.
        if (userNftTokenID > 0) {
            return nftHolderAttributes[userNftTokenID];
            // else, return an empty character
        } else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function attackBoss() public {
        // Get the state of the player's NFT
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "Player with character %s is about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        // Make sure the player has more than 0 HP.
        require(player.hp > 0, "Error: character must have HP to attack boss.");

        // Make sure the boss has more than 0 HP.
        require(bigBoss.hp > 0, "Error: boss must have HP to attack boss.");

        // Allow player to attack boss.
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        // Allow boss to attack player.

        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        // Consoles
        console.log("Player attacked boss. New boss hp is %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp is %s", player.hp);

        emit AttackComplete(msg.sender, bigBoss.hp, player.hp);
    }

    // Users would be able ot hit this function and mint their NFT based on the character index they send in
    function mintCharacterNFT(uint256 _characterIndex) external {
        // Get current tokenID (starts at 1 since we incemented in the constructor)
        uint256 newItemId = _tokenIds.current();

        // The magical function that assigns the tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        // We map the tokenId => their character attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            characterType: defaultCharacters[_characterIndex].characterType,
            crit: defaultCharacters[_characterIndex].crit
        });
        console.log(
            "Minted NFT with tokenId %s and characterIndex %s ",
            newItemId,
            _characterIndex
        );

        // keep an easy way to see who owns what NFT
        nftHolders[msg.sender] = newItemId;

        // Increment the tokenId after mint for the next person who uses it
        _tokenIds.increment();

        // update addresses array
        players.push(payable(msg.sender));

        // Fire CharacterNFTMinted event
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );
        string memory strCrit = Strings.toString(charAttributes.crit);

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                " # ",
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "ipfs://',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',
                strHp,
                ', "max_value":',
                strMaxHp,
                '}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,
                '}, { "trait_type": "Crit", "value": ',
                strCrit,
                '}, { "trait_type": "Type", "value":"',
                charAttributes.characterType,
                '"} ]}'
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
