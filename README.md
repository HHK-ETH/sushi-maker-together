# <h1 align="center"> Let's serve sushi together ! </h1>

Community faucet to maintain the Bar served, users serving the bar get reimbursed the gas cost (only baseFee) :sushi:

## WAIT WHAT ?

**Anyone can donate ETH to the contract, once donated, ETH can not be claimed back.**

/!\ ITS A DONATION /!\

Nevertheless, we can imagine poaps, leaderboard and other things to incentives donations.

**Anyone can serve the Bar and receive a compensation if :**

* Bar hasn't been served in the last 72 hours.
* Sushi price is 5% or more under the 7D TWAP price (BUY THE DIP).
* Block.baseFee < X GWEI, starts at 50 GWEI then increase by 1 GWEI every hours (Don't serve the bar when gas spike).

## HOLLY F*** ITS BUILT ON TOP OF BENTOBOX

its built on BentoBox so ETH sent are wrapped into WETH and earn interest.

When someone serves the Bar, the contract reimburse him by sending WETH to the user's BentoBox account.
