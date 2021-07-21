// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ITypes.sol";

interface ICallee {
    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    ) external;
}
