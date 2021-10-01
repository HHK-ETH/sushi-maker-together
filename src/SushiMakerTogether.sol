// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./mocks/SushiBar.sol";
import "ds-test/test.sol";

contract SushiMakerTogether is Ownable {

    using SafeERC20 for IERC20;
    using SafeERC20 for SushiBar;

    //Let's make Sushis together !
    //                     
    //             ██████████████████
    //       ██████▒▒▒▒▒▒██████▒▒▒▒▒▒██
    //     ██▒▒▒▒░░░░░░░░██████░░░░░░░░██
    //   ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██████▒▒▒▒▒▒▒▒██
    // ██▒▒▒▒▓▓██        ▓▓████        ██
    // ██▒▒▓▓░░██        ██████        ██
    // ░░██▓▓    ▓▓▓▓▓▓░░████████▓▓▓▓██
    //

    SushiBar public sushiBar; //address of the sushiBar
    IERC20 public sushi; //address of the sushi token
    
    uint256 public LOCKED_ON_SERVING = 50; //Fee locked in the contract, start at 50%

    uint256 public totalSushi = 0; //total sushi deposited

    mapping (address => uint256) public balanceOf; //Balance of users that deposit Sushi in the contract

    constructor(IERC20 _sushi, SushiBar _sushiBar, address _opsMultisig) {
        sushi = _sushi;
        sushiBar = _sushiBar;
        transferOwnership(_opsMultisig);
        sushi.approve(address(sushiBar), type(uint256).max);
    }

    //deposit Sushi or xSushi in contract
    function deposit(uint256 _amount, address _to, bool isSushi) external {
        if (isSushi) {
            //deposit Sushi
            balanceOf[_to] += _amount;
            totalSushi += _amount;
            sushi.safeTransferFrom(msg.sender, address(this), _amount);
            sushiBar.enter(sushi.balanceOf(address(this)));
        }
        else {
            //deposit xSushi
            uint256 sushiValue = xSushiToSushi(_amount);
            balanceOf[_to] += sushiValue;
            totalSushi += sushiValue;
            sushiBar.safeTransferFrom(msg.sender, address(this), _amount);
        }
    }

    //Withdraw Sushi or xSushi from contract
    function withdraw(uint256 _amount, address _to, bool isSushi) external {
        if (isSushi) {
            //withdraw Sushi
            sushiBar.leave(sushiToXSushi(_amount));
            balanceOf[msg.sender] -= _amount; //revert on underflow
            totalSushi -= _amount;
            sushi.safeTransfer(_to, _amount);
        }
        else {
            //withdraw xSushi
            uint256 sushiValue = xSushiToSushi(_amount);
            balanceOf[msg.sender] -= sushiValue; //revert on underflow
            totalSushi -= sushiValue;
            sushiBar.safeTransfer(_to, _amount);
        }
    }

    //claim interest generated since last claim
    function claim(address _to) external {
        //calcul profits
        uint256 xSushiBalance = sushiBar.balanceOf(address(this));
        uint256 newTotalSushi = xSushiToSushi(xSushiBalance);
        uint256 profits = newTotalSushi - totalSushi;
        //distribute profits update total sushi
        totalSushi += profits;
        balanceOf[_to] += profits * (100 - LOCKED_ON_SERVING) / 100;
        balanceOf[this.owner()] += profits * LOCKED_ON_SERVING / 100;
    }

    //return Sushi value for a xSushi amount
    function xSushiToSushi(uint256 _amount) public view returns (uint256) {
        uint256 totalSushiInSushiBar = sushi.balanceOf(address(sushiBar));
        uint256 totalShares = sushiBar.totalSupply();
        return _amount * totalSushiInSushiBar / totalShares;
    }
    
    //return xSushi value for a Sushi amount
    function sushiToXSushi(uint256 _amount) public view returns (uint256) {
        uint256 totalSushiInSushiBar = sushi.balanceOf(address(sushiBar));
        uint256 totalShares = sushiBar.totalSupply();
        return _amount * totalShares / totalSushiInSushiBar;
    }

    //update fee on serving, can be called only by the owner => OPS multisig
    function updateFeeOnServing(uint256 _lockedOnServing) onlyOwner external {
        LOCKED_ON_SERVING = _lockedOnServing;
    }
}
