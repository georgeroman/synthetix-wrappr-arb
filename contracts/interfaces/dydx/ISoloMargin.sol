// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ITypes.sol";

interface ISoloMargin {
    function operate(
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) external;
}
