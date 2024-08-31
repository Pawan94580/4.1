# MysticVault Smart Contract

MysticVault is a Solidity-based smart contract that allows users to mine crystals, search, trade crystals for artifacts, and collect various artifact rarities It combines CrystalToken and ArtifactToken to provide a gamified experience within the Ethereum blockchain.

## Description

MysticVault is a decentralized smart contract built on the Ethereum blockchain using Solidity. The contract allows users to mine crystals over time, engage in quests that can yield rewards or risks, and trade their crystals for artifacts. The artifacts come in different rarities, including Common, Uncommon, Rare, Epic, and Legendary, each requiring different amounts of crystal tokens to redeem. The contract also supports the transfer of artifacts between users and the burning of tokens to mint artifacts in the player's collection. MysticVault integrates with CrystalToken and ArtifactToken to handle token transfers and balances, offering a gamified and collectible-focused experience.
## Getting Started

In this assessment, I have used remix IDE [https://remix.ethereum.org/]

### Executing program
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ICrystalBurnable.sol";
import "./CrystalToken.sol";
import "./ArtifactToken.sol";

contract MysticVault {
    using SafeMath for uint;

    CrystalToken public crystalToken;
    ArtifactToken public artifactToken;
    uint public constant crystalMiningRate = 10;

    address public immutable vaultKeeper;
    mapping(address => bool) public isMiningActive;
    mapping(address => uint) public miningStartTime;
    mapping(address => uint) public crystalBalance;
    mapping(address => uint) public artifactBalance;
    mapping(address => uint) public stakedCrystal;

    enum ArtifactRarity {Common, Uncommon, Rare, Epic, Legendary}

    struct PlayerCollection {
        uint commonArtifacts;
        uint uncommonArtifacts;
        uint rareArtifacts;
        uint epicArtifacts;
        uint legendaryArtifacts;
    }

    mapping(address => PlayerCollection) public playerCollection;

    constructor(address _crystalToken, address _artifactToken) {
        crystalToken = CrystalToken(_crystalToken);
        artifactToken = ArtifactToken(_artifactToken);
        vaultKeeper = msg.sender;
    }

    function startMining() public {
        miningStartTime[msg.sender] = block.timestamp;
        isMiningActive[msg.sender] = true;
    }

    function calculateMiningRewards() public view returns (uint) {
        require(isMiningActive[msg.sender], "Mining is not active");
        uint totalMiningTime = block.timestamp - miningStartTime[msg.sender];
        uint earnedCrystals = crystalMiningRate * totalMiningTime;
        return earnedCrystals;
    }

    function claimCrystalRewards() public {
        require(isMiningActive[msg.sender], "Mining has not started");
        uint totalMiningTime = block.timestamp - miningStartTime[msg.sender];
        uint earnedCrystals = crystalMiningRate * totalMiningTime;

        crystalBalance[msg.sender] += earnedCrystals;
        miningStartTime[msg.sender] = block.timestamp;
    }

    function engageInQuest() public {
        require(crystalBalance[msg.sender] >= 20, "Insufficient crystal balance");
        crystalBalance[msg.sender] -= 20;
        uint randomOutcome = block.timestamp % 10;
        if (randomOutcome % 2 == 0) {
            // Successful quest
            crystalBalance[msg.sender] += 100;
        }
    }

    function tradeCrystalsForArtifacts(uint crystalAmount) public {
        require(stakedCrystal[msg.sender] == 0, "Previous trade not settled, withdraw artifacts first");
        require(crystalAmount > 0, "Crystal amount must be greater than zero");
        stakedCrystal[msg.sender] += crystalAmount;
        bool success = crystalToken.transferFrom(vaultKeeper, address(this), crystalAmount);
        require(success, "Crystal transfer failed");
        crystalBalance[msg.sender] -= crystalAmount;
    }

    function withdrawArtifacts() public {
        require(stakedCrystal[msg.sender] > 0, "No staked crystals available");
        uint artifactAmount = stakedCrystal[msg.sender] / 10;
        stakedCrystal[msg.sender] = 0;
        bool success = artifactToken.transferFrom(vaultKeeper, msg.sender, artifactAmount);
        require(success, "Artifact withdrawal failed");
        artifactBalance[msg.sender] += artifactAmount;
    }

    function transferArtifacts(address recipient, uint amount) public {
        require(recipient != address(0), "Invalid recipient address");
        require(artifactToken.balanceOf(msg.sender) >= amount, "Insufficient artifact tokens");

        artifactToken.approve(address(this), amount);
        bool success = artifactToken.transferFrom(msg.sender, recipient, amount);
        require(success, "Artifact transfer failed");
        artifactBalance[recipient] += amount;
    }

    function redeemArtifact(ArtifactRarity rarity) public {
        if (rarity == ArtifactRarity.Common) {
            require(artifactBalance[msg.sender] >= 10, "Not enough artifacts");
            playerCollection[msg.sender].commonArtifacts += 1;
            artifactToken.burn(10, msg.sender);
            artifactBalance[msg.sender] -= 10;
        } else if (rarity == ArtifactRarity.Uncommon) {
            require(artifactBalance[msg.sender] >= 20, "Not enough artifacts");
            playerCollection[msg.sender].uncommonArtifacts += 1;
            artifactToken.burn(20, msg.sender);
            artifactBalance[msg.sender] -= 20;
        } else if (rarity == ArtifactRarity.Rare) {
            require(artifactBalance[msg.sender] >= 30, "Not enough artifacts");
            playerCollection[msg.sender].rareArtifacts += 1;
            artifactToken.burn(30, msg.sender);
            artifactBalance[msg.sender] -= 30;
        } else if (rarity == ArtifactRarity.Epic) {
            require(artifactBalance[msg.sender] >= 40, "Not enough artifacts");
            playerCollection[msg.sender].epicArtifacts += 1;
            artifactToken.burn(40, msg.sender);
            artifactBalance[msg.sender] -= 40;
        } else if (rarity == ArtifactRarity.Legendary) {
            require(artifactBalance[msg.sender] >= 50, "Not enough artifacts");
            playerCollection[msg.sender].legendaryArtifacts += 1;
            artifactToken.burn(50, msg.sender);
            artifactBalance[msg.sender] -= 50;
        } else {
            revert("Invalid artifact rarity selected");
        }
    }
}

```
To compile the code, click on the "Solidity Compiler" tab in the left-hand sidebar. Make sure the "Compiler" option is set to "0.8.7" (or another compatible version), and then click on the button.

Once the code is compiled, you can deploy the contract by clicking on the "Deploy & Run Transactions" tab in the left-hand sidebar. Select the contract from the dropdown menu, and then click on the "Deploy" button.

## Authors

Pawan Kumar - (https://www.linkedin.com/in/pawan-pandey-540a94266/)


## License

This project is licensed under the MIT License
