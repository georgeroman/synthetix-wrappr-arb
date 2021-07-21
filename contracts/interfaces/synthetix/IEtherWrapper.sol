// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IEtherWrapper {
    function mint(uint256 amountIn) external;

    function burn(uint256 amountIn) external;

    function capacity() external view returns (uint256);

    function calculateMintFee(uint256 amount) external view returns (uint256);
}
