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

        //give sushi tokens to users
        sushi.mint(address(userA), 2_000 * 10**18);
        sushi.mint(address(userB), 2_000 * 10**18);
        sushi.mint(address(multisig), 2_000 * 10**18);
    }

    function test_depositSushiFromMultisig(uint8 _amount) public {
        multisig.approveSushi(address(sushiMakerTogether), _amount);
        multisig.deposit(_amount, address(multisig), true);
    }

}