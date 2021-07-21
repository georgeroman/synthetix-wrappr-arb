// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./BaseEtherWrapprArb.sol";

import "./interfaces/aave/IFlashLoanReceiver.sol";
import "./interfaces/aave/ILendingPool.sol";

contract AaveEtherWrapprArb is BaseEtherWrapprArb, IFlashLoanReceiver {
    address public override ADDRESSES_PROVIDER =
        address(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5);

    address public override LENDING_POOL =
        address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    constructor(address _arber) BaseEtherWrapprArb(_arber) {
        IERC20(WETH).approve(LENDING_POOL, type(uint256).max);
    }

    function customTrigger(uint256 amount) internal override {
        address[] memory assets = new address[](1);
        assets[0] = WETH;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        ILendingPool(LENDING_POOL).flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            "",
            0
        );
    }

    function executeOperation(
        address[] calldata,
        uint256[] calldata amounts,
        uint256[] calldata,
        address initiator,
        bytes calldata
    ) external override returns (bool) {
        require(initiator == address(this), "AaveEtherWrapprArb: Unauthorized");

        arb(amounts[0]);
        return true;
    }
}
