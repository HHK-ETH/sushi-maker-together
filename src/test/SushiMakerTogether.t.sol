// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "./../mocks/SushiToken.sol";
import "./../mocks/SushiBar.sol";
import "./../SushiMakerTogether.sol";
import "./utils/User.sol";

contract SushiMakerTogetherTest is DSTest {
    SushiMakerTogether internal sushiMakerTogether;
    SushiBar internal sushiBar;
    SushiToken internal sushi;
    User internal userA;
    User internal userB;
    User internal multisig;

    function setUp() public {
        //deploy sushi & sushiBar
        sushi = new SushiToken();
        sushiBar = new SushiBar(sushi);

        //bootstrap sushiBar with msg.sender
        sushi.mint(address(this), 2_000 * 10**18);
        sushi.approve(address(sushiBar), 1500 * 10**18);
        sushiBar.enter(1500 * 10**18);
        sushi.transfer(address(sushiBar), 500 * 10**18);

        //deploy SushiMakerTogether & users
        sushiMakerTogether = new SushiMakerTogether(sushi, sushiBar, address(this));
        userA = new User(sushi, sushiBar, sushiMakerTogether);
        userB = new User(sushi, sushiBar, sushiMakerTogether);
        multisig = new User(sushi, sushiBar, sushiMakerTogether);

        //transfer ownership to multisig user once deployed
        sushiMakerTogether.transferOwnership(address(multisig));

        //give sushi uint16.max tokens to users
        sushi.mint(address(userA), 65535 * 10**18);
        sushi.mint(address(userB), 65535 * 10**18);
        sushi.mint(address(multisig), 65535 * 10**18);
    }

    function test_depositSushiFromMultisig(uint16 _amount) public {
        uint256 amount = uint256(_amount) * 10**18; //convert decimals
        //pre balances
        uint256 preBalance = sushiMakerTogether.balanceOf(address(multisig));
        uint256 preTotalSushi = sushiMakerTogether.totalSushi();
        //deposit
        multisig.approveSushi(address(sushiMakerTogether), amount);
        multisig.deposit(amount, address(multisig), true);
        //post balances
        uint256 postBalance = sushiMakerTogether.balanceOf(address(multisig));
        uint256 postTotalSushi = sushiMakerTogether.totalSushi();
        //asserts
        assertEq(preBalance + amount, postBalance);
        assertEq(preTotalSushi + amount, postTotalSushi);
    }

    function test_depositXSushiFromMultisig(uint16 _amount) public {
        uint256 amount = uint256(_amount) * 10**18; //convert decimals
        //pre balances
        uint256 preBalance = sushiMakerTogether.balanceOf(address(multisig));
        uint256 preTotalSushi = sushiMakerTogether.totalSushi();
        //convert into xSUSHI
        multisig.approveSushi(address(sushiBar), amount);
        multisig.enter(amount);
        uint256 amountXSushi = sushiBar.balanceOf(address(multisig));
        //deposit
        multisig.approveXSushi(address(sushiMakerTogether), amountXSushi);
        multisig.deposit(amountXSushi, address(multisig), false);
        //post balances
        uint256 postBalance = sushiMakerTogether.balanceOf(address(multisig));
        uint256 postTotalSushi = sushiMakerTogether.totalSushi();
        //asserts
        assertEq(preBalance + amount, postBalance);
        assertEq(preTotalSushi + amount, postTotalSushi);
    }

}