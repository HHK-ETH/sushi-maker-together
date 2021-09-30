// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ISushiBar.sol";
import "ds-test/test.sol";

contract SushiMakerTogether is Ownable {

    using SafeERC20 for IERC20;
    using SafeERC20 for ISushiBar;

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

    ISushiBar public sushiBar; //address of the sushiBar
    IERC20 public sushi; //address of the sushi token
    
    uint256 public LOCKED_ON_SERVING = 50; //Fee locked in the contract, start at 50%

    uint256 public lastRatio; //Last xSUSHI<=>SUSHI ratio to determinate the profits made
    uint256 public lastClaim; //Last claim date

    mapping (address => uint256) public balanceOf; //Balance of users that deposit Sushi in the contract

    constructor(IERC20 _sushi, ISushiBar _sushiBar, address _opsMultisig) {
        sushi = _sushi;
        sushiBar = _sushiBar;
        transferOwnership(_opsMultisig);
        lastRatio = getRatio();
        lastClaim = block.timestamp;
    }

    //deposit Sushi or xSushi in contract
    function deposit(uint256 _amount, address _to, bool isSushi) external {
        if (isSushi) {
            //deposit Sushi
            balanceOf[_to] += _amount;
            sushi.safeTransferFrom(msg.sender, address(this), _amount);
            sushiBar.enter(sushi.balanceOf(address(this)));
        }
        else {
            //deposit xSUSHI
            uint256 ratio = getRatio();
            //update ratio, if not updated and ratio > lastRatio a part of the deposit will be claimed resulting in a small loss for the user
            lastRatio = ratio;
            balanceOf[_to] += _amount * ratio;
            sushiBar.safeTransferFrom(msg.sender, address(this), _amount);
        }
    }

    //Withdraw Sushi or xSushi from contract
    function withdraw(uint256 _amount, address _to, bool isSushi) external {
        if (isSushi) {
            //withdraw Sushi
            sushiBar.leave(_amount / lastRatio);
            balanceOf[msg.sender] -= _amount; //revert on underflow
            sushi.safeTransfer(_to, _amount);
        }
        else {
            //withdraw xSushi
            balanceOf[msg.sender] -= _amount * lastRatio; //revert on underflow
            sushiBar.safeTransfer(_to, _amount);
        }
    }

    //claim interest generated since last claim
    function claim(address _to) external {
        uint256 newRatio = getRatio();
        require(lastRatio < newRatio, "SushiMakerTogether: SERVE THE BAR BEFORE CLAIMING");
        //calcul profits
        uint256 xSushiBalance = sushiBar.balanceOf(address(this));
        uint256 previousSushiBalance = xSushiBalance * lastRatio;
        uint256 newSushiBalance = xSushiBalance * newRatio;
        uint256 profits = newSushiBalance - previousSushiBalance;
        //distribute profits
        balanceOf[_to] += profits * (100 - LOCKED_ON_SERVING) / 100;
        balanceOf[this.owner()] += profits * LOCKED_ON_SERVING / 100;
        //update ratio
        lastRatio = newRatio;
    }

    //calculate current xSUSHI<=>SUSHI ratio
    function getRatio() internal view returns (uint256) {
        uint256 totalSushiInSushiBar = sushi.balanceOf(address(sushiBar));
        uint256 totalShares = sushiBar.totalSupply();
        return totalSushiInSushiBar / totalShares;
    }

    //update fee on serving, can be called only by the owner => OPS multisig
    function updateFeeOnServing(uint256 _lockedOnServing) onlyOwner external {
        LOCKED_ON_SERVING = _lockedOnServing;
    }
}
