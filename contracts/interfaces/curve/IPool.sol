// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IPool {
    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external returns (uint256);
}
