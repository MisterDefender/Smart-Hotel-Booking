// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    constructor() ERC20("USDT Token", "USDT") {}

    function faucetTokens(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
