// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

// WARNING: There is a known vuln contained within this contract related to vote delegation, 
// it's NOT recommmended to use this in production.  

// SushiToken with Governance.
contract SushiToken is ERC20("SushiToken", "SUSHI"), Ownable {
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (MasterChef).
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}