# <h1 align="center"> Let's serve sushi together ! </h1>

Community faucet to maintain the Bar served, users serving the bar receive a part of the profits to reimburse gas costs :sushi:

## How does it works ?

Anyone can send Sushi to the contract.

Sushi deposited are staked in the SushiBar.

Users will not receive any profits from the SushiBar but can redeem their initial deposit whenever they want.

Because the SushiMaker contract can't be called from another contract.
When someone wants to serve the Bar, he will have to submit a flashbots bundle containing this contract and SushiMaker contract.

Here is the bundle explained :

* Call convertMultiple with the list of LPs to transform into Sushi on SushiMaker contract : serves the Bar.
* Call claim on SushiMakerTogether contract : claim 50% of the benefits generated for xSUSHI sitting in the SushiMakerTogether contract since last claim.

**What happens to the other 50% ?**

They are locked in the contract to achieve selfsustaining.
The idea is that the community and Sushi treasury bootstrap it until it can pays for itself.
When reached, everyone can unstake their Sushi tokens and we will have incentive for serving the Bar forever :)

But this requires a lot of xSUSHI in the contract, so other solution would be to set it to 0 and just lock the xSUSHI from OPS multisig. (see simulations)

**Other specifications:**

* OPS multisig can change the 50% fees locked in the contract because at one point if enough Sushi are locked, it makes no sense to lock more, so OPS multisg can set it to 0%, then 100% will go to the user serving the Bar.
* OPS multisig can also claim all the Sushi locked from fees in the contract (not the tokens of the users just the one locked from fees), in case the contract needs to be updated.

**Potential Improvements**
* Add a register function so no need to use flashbots : register function take the address of the caller and lock the claim to only this address for the x coming blocks. This way the user serving the Bar has x block to serve and claim without being worried of frontrunning. But since this will cost more gas, I think for now flashbots bundle are better.

**Simulations**
* the 4th of october 2021, OPS multisig has 48,351 xSUSHI and total xSUSHI supply is 65,836,829. Serving the top10 LP fees cost around 300-350$ , if we imagine serving when it represents 500k$ (usually takes less than a week). It will generate 372$ for xSUSHI sitting in the multisig. If they were in sushiMakerTogether instead and 100% given to the user serving the bar, it would be enough to reimburse the gas fees.

**Personnal opinion**

I think this could be a cool way to make the serving automatic. Since users can earn on serving you can be sure that at least one user will be monitoring the contract.

But this contract (even if its a simple contract) add risks (ex: exploit of SushiMakerTogether leading to funds stolen) for something that can be done manually and doesn't cost that much money and time.

So going forward I'm not sure if its really worth pushing it into production, happy to hear any feedback !

Thanks to @Stack_bot for helping finding this idea.