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
        multisig = new User(sushi, sushiBar, sushiMakerTogether);
        userA = new User(sushi, sushiBar, sushiMakerTogether);

        //transfer ownership to multisig user once deployed
        sushiMakerTogether.transferOwnership(address(multisig));

        //give sushi uint16.max tokens to multisig
        sushi.mint(address(multisig), 65535 * 10**18);
    }

    function test_deposit_sushi(uint16 _amount) public {
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

    function test_deposit_xSushi(uint16 _amount) public {
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

    function test_withdraw_sushi(uint16 _amount) public {
        uint256 amount = uint256(_amount) * 10**18; //convert decimals
        uint256 preBalance = sushi.balanceOf(address(multisig));
        //deposit
        multisig.approveSushi(address(sushiMakerTogether), amount);
        multisig.deposit(amount, address(multisig), true);
        //withdraw
        multisig.withdraw(amount, address(multisig), true);
        //asserts
        assertEq(sushiMakerTogether.balanceOf(address(multisig)), 0);
        assertEq(sushi.balanceOf(address(multisig)), preBalance);
    }
    
    function test_withdraw_xSushi(uint16 _amount) public {
        uint256 amount = uint256(_amount) * 10**18; //convert decimals
        uint256 amountInXSushi = sushiMakerTogether.sushiToXSushi(amount);
        //deposit
        multisig.approveSushi(address(sushiMakerTogether), amount);
        multisig.deposit(amount, address(multisig), true);
        //withdraw
        multisig.withdraw(amountInXSushi, address(multisig), false);
        //asserts
        assertEq(sushiMakerTogether.balanceOf(address(multisig)), 0);
        assertEq(sushiBar.balanceOf(address(multisig)), amountInXSushi);
    }

    function testFail_withdraw_more_sushi_than_deposited(uint16 _amount) public {
        uint256 amount = uint256(_amount) * 10**18; //convert decimals
        //deposit
        multisig.approveSushi(address(sushiMakerTogether), amount);
        multisig.deposit(amount, address(multisig), true);
        //withdraw
        multisig.withdraw(amount + 1, address(multisig), true);
    }

    function test_update_lockedOnServing() public {
        multisig.updateLockedOnServing(20);
        assertEq(20, sushiMakerTogether.LOCKED_ON_SERVING());
    }
    
    function testFail_update_lockedOnServing_not_owner() public {
        sushiMakerTogether.updateLockedOnServing(20);
    }

    function test_claim_no_profits() public {
        //pre balances
        uint256 preBalance = sushiMakerTogether.balanceOf(address(multisig));
        uint256 preTotalSushi = sushiMakerTogether.totalSushi();
        //claim
        multisig.claim(address(multisig));
        //asserts
        assertEq(sushiMakerTogether.balanceOf(address(multisig)), preBalance);
        assertEq(sushiMakerTogether.totalSushi(), preTotalSushi);
    }

    function test_claim_profits(uint16 _amount) public {
        uint256 amount = uint256(_amount) * 10**18; //convert decimals
        //pre balances
        uint256 preBalanceMultisig = sushiMakerTogether.balanceOf(address(multisig));
        uint256 preBalanceUserA = sushiMakerTogether.balanceOf(address(userA));
        uint256 preTotalSushi = sushiMakerTogether.totalSushi();
        //serve the bar
        sushi.mint(address(sushiBar), amount);
        //userA claim
        sushiMakerTogether.claim(address(userA));
        //post balances
        uint256 postTotalSushi = sushiMakerTogether.xSushiToSushi(sushiBar.balanceOf(address(sushiMakerTogether)));
        uint256 profits = postTotalSushi - preTotalSushi;
        //asserts
        assertEq(preTotalSushi + profits, postTotalSushi);
        assertEq(preBalanceMultisig + (profits * sushiMakerTogether.LOCKED_ON_SERVING() / 100), sushiMakerTogether.balanceOf(address(multisig)));
        assertEq(preBalanceUserA + (profits * (100 - sushiMakerTogether.LOCKED_ON_SERVING()) / 100), sushiMakerTogether.balanceOf(address(userA)));
    }

}