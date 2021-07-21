// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/curve/IPool.sol";
import "./interfaces/synthetix/IEtherWrapper.sol";
import "./interfaces/IWETH9.sol";

abstract contract BaseEtherWrapprArb {
    address internal constant ETHER_WRAPPER =
        address(0xC1AAE9d18bBe386B102435a8632C8063d31e747C);

    address internal constant WETH =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address internal constant SETH =
        address(0x5e74C9036fb86BD7eCdcb084a0673EFc32eA31cb);

    address internal constant CURVE_SETH_ETH_POOL =
        address(0xc5424B857f758E906013F3555Dad202e4bdB4567);

    address internal arber;

    modifier onlyArber {
        require(msg.sender == arber, "Unauthorized");
        _;
    }

    constructor(address _arber) {
        arber = _arber;
    }

    receive() external payable {
        // Needed for exchanging sETH to ETH on Curve
    }

    function customTrigger(uint256 amount) internal virtual;

    function arb(uint256 amount) internal {
        // Initially, we have `amount` flash loaned WETH

        // Mint sETH
        IERC20(WETH).approve(ETHER_WRAPPER, amount);
        IEtherWrapper(ETHER_WRAPPER).mint(amount);

        // Swap sETH to ETH on Curve
        uint256 sethBalance = IERC20(SETH).balanceOf(address(this));
        IERC20(SETH).approve(CURVE_SETH_ETH_POOL, sethBalance);
        uint256 ethBalance = IPool(CURVE_SETH_ETH_POOL).exchange(
            1,
            0,
            sethBalance,
            1
        );

        // Wrap the ETH to WETH
        IWETH9(WETH).deposit{value: ethBalance}();

        // Any WETH not paid back to the flash loan is profit
    }

    function trigger(uint256 amount) external onlyArber {
        customTrigger(amount);
    }

    function claim() external onlyArber {
        uint256 profit = IERC20(WETH).balanceOf(address(this));
        IERC20(WETH).transfer(arber, profit);
    }
}
