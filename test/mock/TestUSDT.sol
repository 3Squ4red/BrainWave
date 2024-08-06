// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {

    constructor() ERC20("Tether USD", "USDT") {}

    function decimals() public pure override returns(uint8) {
        return 6;
    }

    function mint(address a, uint x) external {
        _mint(a, x);
    }
}
