// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PermitToken is ERC20, ERC20Permit {
    constructor() ERC20("PermitToken", "PT") ERC20Permit("PermitToken") {
        _mint(msg.sender, 1 * 10 ** decimals());
    }
}