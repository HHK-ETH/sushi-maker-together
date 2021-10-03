// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "./../mocks/SushiToken.sol";
import "./../mocks/SushiBar.sol";
import "./../SushiMakerTogether.sol";

contract SushiMakerTogetherTest is DSTest {
    SushiMakerTogether internal sushiMakerTogether;
    SushiBar internal sushiBar;
    SushiToken internal sushi;

    function setUp() public {
        //deploy sushi & sushiBar
        sushi = new SushiToken();
        sushiBar = new SushiBar(sushi);

        //bootstrap sushiBar
        sushi.mint(address(this), 3_000 * 10**18);
        sushi.approve(address(sushiBar), 1_500 * 10**18);
        sushiBar.enter(1_500 * 10**18);
        sushi.transfer(address(sushiBar), 500 * 10**18);

        //deploy SushiMakerTogether
        sushiMakerTogether = new SushiMakerTogether(sushi, sushiBar, msg.sender);

        //approve sushiMakerTogether
        sushi.approve(address(sushiMakerTogether), 1000 * 10**18);
        sushiBar.approve(address(sushiMakerTogether), 1000 * 10**18);
        //deposit to test withdraw
        sushiMakerTogether.deposit(100 * 10**18, address(this), true);
    }

    function test_gas_deposit_sushi() public {
        sushiMakerTogether.deposit(10 * 10**18, address(this), true);
    }

    function test_gas_deposit_xSushi() public {
        sushiMakerTogether.deposit(10 * 10**18, address(this), false);
    }

    function test_gas_withdraw_sushi() public {
        sushiMakerTogether.withdraw(10 * 10**18, address(this), true);
    }
    
    function test_gas_withdraw_xSushi() public {
        sushiMakerTogether.withdraw(10 * 10**18, address(this), false);
    }

    function test_gas_claim() public {
        sushiMakerTogether.claim(address(this));
    }

}