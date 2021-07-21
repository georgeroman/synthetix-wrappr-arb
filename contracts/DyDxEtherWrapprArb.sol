// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./interfaces/dydx/ICallee.sol";
import "./interfaces/dydx/ISoloMargin.sol";

import "./BaseEtherWrapprArb.sol";

contract DyDxEtherWrapprArb is BaseEtherWrapprArb, ICallee {
    address internal constant SOLO_MARGIN =
        address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    constructor(address _arber) BaseEtherWrapprArb(_arber) {
        IERC20(WETH).approve(SOLO_MARGIN, type(uint256).max);
    }

    function customTrigger(uint256 amount) internal override {
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);
        operations[0] = Actions.ActionArgs({
            actionType: Actions.ActionType.Withdraw,
            accountId: 0,
            amount: Types.AssetAmount({
                sign: false,
                denomination: Types.AssetDenomination.Wei,
                ref: Types.AssetReference.Delta,
                value: amount
            }),
            primaryMarketId: 0,
            secondaryMarketId: 0,
            otherAddress: address(this),
            otherAccountId: 0,
            data: ""
        });
        operations[1] = Actions.ActionArgs({
            actionType: Actions.ActionType.Call,
            accountId: 0,
            amount: Types.AssetAmount({
                sign: false,
                denomination: Types.AssetDenomination.Wei,
                ref: Types.AssetReference.Delta,
                value: 0
            }),
            primaryMarketId: 0,
            secondaryMarketId: 0,
            otherAddress: address(this),
            otherAccountId: 0,
            data: abi.encode(amount)
        });
        operations[2] = Actions.ActionArgs({
            actionType: Actions.ActionType.Deposit,
            accountId: 0,
            amount: Types.AssetAmount({
                sign: true,
                denomination: Types.AssetDenomination.Wei,
                ref: Types.AssetReference.Delta,
                // DyDx has a 2 wei fee
                value: amount + 2
            }),
            primaryMarketId: 0,
            secondaryMarketId: 0,
            otherAddress: address(this),
            otherAccountId: 0,
            data: ""
        });

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = Account.Info({owner: address(this), number: 1});

        ISoloMargin(SOLO_MARGIN).operate(accountInfos, operations);
    }

    function callFunction(
        address sender,
        Account.Info memory,
        bytes memory data
    ) external override {
        uint256 amount = abi.decode(data, (uint256));
        require(sender == address(this), "DyDxEtherWrapprArb: Unauthorized");

        arb(amount);
    }
}
