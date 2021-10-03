// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./mocks/SushiBar.sol";
import "ds-test/test.sol";

contract SushiMakerTogether is Ownable {

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
    //Open vault where anyone can deposit his Sushi/xSushi to share sushiBar APY with users serving the bar.

    using SafeERC20 for IERC20;
    using SafeERC20 for SushiBar;

    event LogDeposit(address indexed from, address indexed to, uint256 amount, bool isSushi);
    event LogWithdraw(address indexed from, address indexed to, uint256 amount, bool isSushi);
    event LogClaim(address indexed from, address indexed to, uint256 profits);
    event LogUpdateLockedOnServing(uint256 LOCKED_ON_SERVING);

    SushiBar internal immutable sushiBar; //address of the sushiBar
    IERC20 internal immutable sushi; //address of the sushi token
    
    uint256 public LOCKED_ON_SERVING = 50; //Fee locked in the contract, start at 50%

    uint256 public totalSushi; //total sushi deposited, start at 0

    mapping (address => uint256) public balanceOf; //Balance of users that deposit Sushi in the contract

    constructor(IERC20 _sushi, SushiBar _sushiBar, address _opsMultisig) {
        sushi = _sushi;
        sushiBar = _sushiBar;
        transferOwnership(_opsMultisig);
        _sushi.approve(address(_sushiBar), type(uint256).max);
    }

    //deposit Sushi or xSushi in contract
    function deposit(uint256 _amount, address _to, bool _isSushi) external {
        if (_isSushi) {
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
        emit LogDeposit(msg.sender, _to, _amount, _isSushi);
    }

    //Withdraw Sushi or xSushi from contract
    function withdraw(uint256 _amount, address _to, bool _isSushi) external {
        if (_isSushi) {
            //withdraw Sushi
            sushiBar.leave(sushiToXSushi(_amount));
            balanceOf[msg.sender] -= _amount;
            totalSushi -= _amount;
            sushi.safeTransfer(_to, _amount);
        }
        else {
            //withdraw xSushi
            uint256 sushiValue = xSushiToSushi(_amount);
            balanceOf[msg.sender] -= sushiValue;
            totalSushi -= sushiValue;
            sushiBar.safeTransfer(_to, _amount);
        }
        emit LogWithdraw(msg.sender, _to, _amount, _isSushi);
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
        emit LogClaim(msg.sender, _to, profits);
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
    //no require or max amount since no funds at risk and we assume OPS MULTISIG is a good actor
    function updateLockedOnServing(uint256 _lockedOnServing) onlyOwner external {
        LOCKED_ON_SERVING = _lockedOnServing;
        emit LogUpdateLockedOnServing(_lockedOnServing);
    }
}
