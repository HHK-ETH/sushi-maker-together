// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISushiBar is IERC20 {
    function leave(uint256 _share) external;
    function enter(uint256 _amount) external;
}