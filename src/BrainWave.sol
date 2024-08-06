// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "forge-std/console.sol";

error ZeroValue();

contract BrainWave is ERC20 {
    using SafeERC20 for IERC20;

    // max supply is 1 million BWT
    uint256 public constant MAX_SUPPLY = 1_000_000 ether;
    IERC20 public immutable USDT;
    address public immutable admin;

    // the price of 1 BWT in USDT
    uint256 public price;
    // usdt balance of this contract
    // prevents manipulation from flash loans
    uint256 private usdtBalance;

    constructor(IERC20 _usdt, address _admin) ERC20("BrainWave", "BWT") {
        USDT = _usdt;
        admin = _admin;

        // the initial price of 1 BWT would be 1 USDT
        price = 1e6;
    }

    // MODIFIERS
    modifier nonZero(uint v) {
        require(v > 0, ZeroValue());
        _;
    }

    // purchase BWT from the specified amount of USDT
    function purchase(uint256 _usdt) external nonZero(_usdt) {
        usdtBalance += _usdt;
        // pull `_usdt` amount of USDT from buyer
        USDT.safeTransferFrom(msg.sender, address(this), _usdt);

        uint256 bwtPurchaseAmount = getAmountOf(_usdt);
        uint256 halfMintAmount = (bwtPurchaseAmount * 4_000) / 10_000;
        _mint(msg.sender, halfMintAmount);
        _mint(admin, halfMintAmount);

        price = usdtBalance / (totalSupply() / (10 ** decimals()));
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        // burn 20% of transfer amount
        uint burnAmount = (value * 2_000) / 10_000;
        _burn(msg.sender, burnAmount);

        // transfer the rest 80% of transfer amount
        super.transfer(to, value - burnAmount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        // burn 20% of transfer amount
        uint burnAmount = (value * 2_000) / 10_000;
        _burn(from, burnAmount);

        // transfer the rest 80% of transfer amount
        super.transferFrom(from, to, value - burnAmount);

        return true;
    }

    // VIEW FUNCTIONS

    // get the amount of BWT tokens that could be purchased from `_usdt` USDT
    /**
    @param _usdt The amount of USDT with decimals
    */
    function getAmountOf(uint256 _usdt) public view returns (uint256 amount) {
        amount = (_usdt / price) * 10 ** decimals();
    }

    // get of price of `_amount` of BWT tokens in USDT
    /**
    @param _amount The amount of BWT without decimals
    */
    function getPriceOf(uint256 _amount) public view returns (uint256 price_) {
        price_ = _amount * price;
    }
}
