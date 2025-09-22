//SPDX-License-Identifier:MIT
// test/mocks/ERC20Harness.sol
pragma solidity ^0.8.18;

import {AkToken} from "../../src/AkToken.sol";

contract ERC20Harness is AkToken {
    constructor(
        uint256 supply,
        string memory name,
        string memory symbol
    ) AkToken(supply, name, symbol) {}

    function exposedMint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function exposedBurn(address from, uint256 amount) external {
        _burn(from, amount);
    }



    // ✅ New: Expose _approve to test invalid owner/spender
    function exposedApprove(
        address owner,
        address spender,
        uint256 amount
    ) external {
        _approve(owner, spender, amount, true);
    }
}
