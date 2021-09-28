# <h1 align="center"> Let's serve sushi together ! </h1>

Community faucet to maintain the Bar served, users serving the bar receive a part of the profits to reimburse gas costs :sushi:

## How does it works ?

Anyone can send Sushi to the contracts.

Sushi deposited are staked in the SushiBar.

Users will not receive any profits from the SushiBar but can redeem their initial deposit whenever they want.

Because the SushiMaker contract can't be called from another contract.
When someone wants to serve the Bar, he will have to submit a flashbots bundle containing this contract and SushiMaker contract.

Here is the bundle explained :

* Call register on SushiMakerTogether contract : register the address of the user that is going to serve the Bar.
* Call convertMultiple with the list of LPs to transform into Sushi on SushiMaker contract : serves the Bar.
* Call claim on SushiMakerTogether contract : receive 50% of the benefits generated for xSUSHI sitting in the SushiMakerTogether contracts.

**What happens to the other 50% ?**

They are locked in the contract to achieve selfsustaining.
The idea is that the community and Sushi treasury bootstrap it until it can pays for hitself.
When reached, anyone can unstake their Sushi tokens and we will have incentive for serving the Bar forever :)

**Other specifications:**

* Register + claim are locked for 12 hours after being succesfully called for security reasons.
* This 12 hours lock can be modified by the OPS multisig as well as the 50% fees locked in the contract, at one point if enough Sushi are locked, it makes no sense to lock more, so OPS multisg can set it to 0%, 100% will go to the user serving the Bar.
* OPS multisig can also claim all the Sushi locked from fees in the contract (not the tokens of the users just the one locked from fees) with a 48hours timelock, in case the contract needs to be updated.

Thanks to @Stack_bot for helping finding this idea.