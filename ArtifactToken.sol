// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ICrystalBurnable.sol";

contract ArtifactToken is ERC20, ICrystalBurnable {
    constructor() ERC20("Artifact", "ART") {
        _mint(msg.sender, 10**18);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function burn(uint amount, address account) public override {
        _burn(account, amount);
    }
}
