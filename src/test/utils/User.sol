// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./../../mocks/SushiToken.sol";
import "./../../mocks/SushiBar.sol";
import "./../../SushiMakerTogether.sol";

contract User {
    SushiMakerTogether internal sushiMakerTogether;
    SushiBar internal sushiBar;
    SushiToken internal sushi;

    constructor(SushiToken _sushi, SushiBar _sushiBar, SushiMakerTogether _sushiMakerTogether) {
        sushi = _sushi;
        sushiBar = _sushiBar;
        sushiMakerTogether = _sushiMakerTogether;
    }

    //tokens
    function approveSushi(address _to, uint256 _amount) public {
        sushi.approve(_to, _amount);
    }
    function approveXSushi(address _to, uint256 _amount) public {
        sushiBar.approve(_to, _amount);
    }
    
    function transferSushi(address _to, uint256 _amount) public {
        sushi.transfer(_to, _amount);
    }
    function transferXSushi(address _to, uint256 _amount) public {
        sushiBar.transfer(_to, _amount);
    }

    //sushiBar
    function enter(uint256 _amount) public {
        sushiBar.enter(_amount);
    }
    function leave(uint256 _amount) public {
        sushiBar.leave(_amount);
    }

    //sushiMakerTogether
    function deposit(uint256 _amount, address _to, bool isSushi) public {
        sushiMakerTogether.deposit(_amount, _to, isSushi);
    }
    function withdraw(uint256 _amount, address _to, bool isSushi) public {
        sushiMakerTogether.withdraw(_amount, _to, isSushi);
    }
    function claim(address _to) public {
        sushiMakerTogether.claim(_to);
    }
    function updateLockedOnServing(uint256 _lockedOnServing) public {
        sushiMakerTogether.updateLockedOnServing(_lockedOnServing);
    }
}