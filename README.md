# ERC20NonDilutive
Enable using a mintable token along with dilution protected preferred shares.
**DISCLAIMER: Project Beta. Use Responsibly.**
[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)

## Description
This project provides a proof of concept of a mintable ERC20 token that offers the possibility of inflation protection through the issuance of ERC721 "preferred shares". These shares are also tradeable but non-fungible (due to the need to track individual claims by token). Whenever tokens are minted, holders of "preferred shares" are offered an additional claim on tokens such as to maintain the proportion of tokens they hold. This enables the usage of 1 token that can be inflated dynamically to incentivize new user onboarding while offering a form of dilution protection for investors.

The rest of this README is split apart into the following sections.
- Token Issuance Economics
- Governance & Regulation
- Contracts: Technical Overview
- Example DApp Issuance: Clash of Tribes

## Token Issuance Economics
### Financing with Programmable Money
Various token distribution models have been experimented with in the past few years. The programmability of tokens offers the opportunity to innovate on different forms of financing. Through the flourishing of different crypto distribution models, entrepreneurs, users, and investors are able to test out different forms of token distribution models which each create different incentive alignment paradigms. 

### Inflation vs Hoarding
One simple characteristic we can use to distinguish tokens is inflation. The most extreme examples on each side of this metric would be a fully inflationary mintable token, and a fixed supply fully liquid token. Both have their respective advantages and disadvantages. While inflation can help bootstrap a community and incentivize the onboarding of new users, it can also severely hurt token holders who hold the asset as an investment. The opposite case of a fixed supply with no inflation, while very conservative for investors, can also have an adverse effect on tokens looking to bootstrap a community of new users who are just looking to use the token and plan on spending it in the short-term. 

Gresham's law of "bad money drives out good" can lead to hoarding and adversely impact newcomers. While some may say that early investors should be compensated for their risks and latecomers should pay a premium, the reality is that often this can hurt adoption and any potential of creating a network of users. This, of course, is one of the common criticisms of bitcoin's strict supply, and while this may suit its usage as sound money or "digital gold", it is clear that for certain use cases, inflation is a good tool to incentivize DApp usage and leverage network effects.

### Current Solutions
Inflation and investors, therefore, seem to always be at odds, yet lack of inflation can lead to difficulty in bootstrapping early adopters, especially post-launch event (ICO, Airdrop, etc...). Here we explore some of the current solutions that take the middle of the road approach in balancing inflation and investor alignment. Note that it may be possible to combine some of these features.

- Infinite Fixed Inflation: There is no cap on the token supply but tokens are minted at a fixed rate enforced by an entity or algorithmically through Proof of Work. Example: ETH (not exactly but more or less predictable with block time)
- Fixed Supply with "Community Incentive Fund": A portion of minted tokens is dedicated to subsidizing the community and new actors. Most importantly, this is different from the "Development Team Fund" which is to incentivize core developers. Example: LINK (Oracle node operator subsidy)
- Fixed Supply with Locked Vesting: Similar to a community fund, certain portions of minted tokens are put aside and time locked. This reduces the tradeable supply in the short-term. The primary characteristic of vesting is delaying liquidity. Example: Ripple (quarterly auto-liquidation)
- Dual token model: Issue two sets of tokens with distinguishing features. This architecture is often used in the context of DAOs where one enables usage while the other enables governance. Example: MKRDAO (DAI/MKR)
- Airdrop: Issue free tokens to onboard new users. This can incentivize marketing and DApp usage. Example: I don't know of any successful examples.

While all of these solutions present an interesting middle ground between inflation and preserving token value, each presents their certain flaws. 

While fixed inflation maintains a subsidy, this is often in the context of rewarding miners and not users, and any excessive increase of inflation would lead to significant token depreciation. 

Models based on locking a fixed supply for a particular group or timescale, while the most simple, suffer from the assumption that said lockup is the "right supply". Indeed how is one supposed to know how much subsidy will be needed? Dedicating too little would make the community bootstrapping ineffective, too much would hurt investors. Burning tokens post-facto is a possibility but is more a patch than an organic solution. Another problem is governance of such "community" funds: often subsidies are dedicated to network operators (aka staking companies) and not to the onboarding of new users who are left out from the subsidy. 

Dual token models are very interesting in that they fully separate the investor from the user. This is an interesting model and various implementations exist. One criticism might be that often the "investor" token is too focused on governance and isolated from the "consumer" token's economy. The most notable example is DAI and MKR. MKR's value currently comes from its voting rights and the DAI stability fee paid to MKR holders. The long-term value of voting rights is debatable. In crypto, this seems quite valuable but traditional stock markets seem to differ in opinion (See Google Class A vs Class C share price). It is also important to note MKR fees are not a feature of MKR but rather of DAI itself. The stability fee is there to maintain the $1 peg. At market equilibrium in the long-run, it is possible that the fee will significantly reduce as the market's demand for leverage reduces.

Airdrops are probably the most innovative and user-focused form of token distribution model. By issuing free tokens, users can experience the product and start experimenting with different use cases. Due to not requiring any investment, users are less likely to hoard the token. Provided they are not followed up by an ICO, Airdrops present the significantly reduced regulatory risk due to not requiring any form of investment from the user. Of course, their fatal flaw is that they do not raise any direct funding for the development of the project. It could be conceivable that a token gain value post-Airdrop through popularity and usage, but gaining popularity requires a good product, and a good product often needs funding. After all, developers have to eat too. One other flaw of Airdrops also present in regular ICOs, is that after the distribution period, new users can no longer be onboarded. Some projects have therefore opted to use longer timescales (> 1 year) but it can be a challenge to determine the "right" timescale.

### Dichotomy of investors & users
We recognize a dichotomy between investors and users. Investors wish to see a return on their investment and therefore wish for high-demand with a scarce supply. Users, on the other hand, are not willing to spend money on testing out a DApp, expect free usage, and often need incentives to keep them engaged.

Some might argue that crypto has seen the emergence of investor-users. While it may be true that a person might be interested both in investing and using the product, a rational investor will always prefer hoarding the token. Often one might say they will use the product "once prices have stabilized" (and they have therefore profited from their investment). One can only become a true user if they relinquish being an investor.

Dual token models attempt to break this dichotomy by issuing a "user" token and an "investor" token. The problem then is capturing the value of the "user" token for investors. Indeed, the scarce asset is the "investor" token but the asset in demand is the "user" token. In the long-run, it becomes necessary to implement value transfer schemes such as built-in fees which can imperfectly capture some of the network value. This most likely adds complexity to the ecosystem in terms of price discovery for the "user" token (especially if this is not a stable-coin).

### 1 token 2 incentives = ERC20NonDilutive
It is often difficult to determine the "right" inflation that balances early-subsidization and investor value. ERC20NonDilutive enables flexibility in terms of minting while preserving investor value. The ERC20NonDilutive token model borrows ideas from Airdrops and Dual Token models to enable isolation of user/investor incentives while using only 1 token. It takes inspiration from traditional VC investing, more specifically, non-dilutive shares. 

Usually, when new shares (or tokens) are issued, existing shareholders see their proportional ownership decline. This is called dilution. This can be beneficial if used for fundraising for example, or hurt shareholder value if done at a reduced valuation. Dilution can also reduce an investor's voting rights. Some investors might wish to be protected from share dilution. Non-dilutive shares exist to protect investors from share dilution. When new shares are issued, owners of non-dilutive shares will also be issued shares proportional to their pre-dilution ownership. If the pre-money valuation is equal to the post-money valuation, a non-diluted shareholder will conserve their investment's value (they own the same proportion). If the post-money valuation is higher, their investment will have increased in value (for regular shareholders, this depends on their dilution, the most famous case being Eduardo Saverin).

ERC20NonDilutive uses an ERC20 mintable token and an ERC721 share to represent "preferred" holders who are inflation protected. In this model, preferred shares are not exactly the same as non-dilutive shares. Instead, we split the instrument of a non-dilutive share into its two components: presently issued shares and a free option on future inflation. That is, owning a non-dilutive share is equivalent to owning regular shares plus the guarantee of getting proportionally more shares when new shares are issued. 

## Contracts
### ERC20NonDilutive.sol
The ERC20 token represents presently issued tokens while ERC721 shares are a promise on future inflation. When new tokens are minted (governance of this is out of scope), additional tokens are minted in excess that can be claimed by holders of preferred shares. The total amount of excess tokens minted is computed as the original amount per common stock `amount/commonStockSupply` multiplied by `preferredStockSupply`. 

Note that there is no real "common" stock. It is simply a number used as the denominator to get the non-dilutive share of "preferred" stock. We could have also used a constant total stock supply of 100 (implying 1% for each preferred stock), but this scheme enables more granularity. Just as tokens can be minted, preferred stock can also be minted dynamically. Note that new preferred stock does not give the right to any tokens, only future tokens. Preferred stock can also be burned by their holders, forgoing any right to future inflation and benefitting regular holders.

Two main challenges posed by having a preferred stock architecture are keeping track of claimed tokens, using a push/pull architecture, and enabling tradeability of the preferred stock. ERC721 solves this in the best way as we do not have to keep track of addresses, but only of the NFTs. Owners can claim issued tokens using their preferred stock and also trade their option. The disintermediation of the shares and dilution protection also enables holding a mixed portfolio (for example that is 50% protected from future inflation).

### ERC721PreferredStock.sol.
Uses ERC721Enumerable, ERC721Mintable, ERC721Burnable. Shares are therefore indexed, can be created and burned at will. The ERC20 token is automatically assigned the minting role. All governance regarding ERC721 minting is therefore delegated to the governance of ERC20 minting.

## Governance & Regulation
### Governance Advantages
One advantage of the ERC20NonDilutive is that governance of token minting is less critical for investors. Many mintable tokens choose to delegate the minting of tokens to a DAO. With ERC20NonDilutive, token minting is less of a concern for investors since inflation protection guarantees they conserve the same proportional stake regardless of the amount minted. Note that this is different from governance of the ERC721 preferred share distribution which **is** of concern to investors as this translates to share dilution. In this proof of concept, both governance roles (token & non-dilution shares) are the same but it would be trivial to disintermediate these roles or simply make the ERC721 distribution permanent (while keeping the token mintable).

### Regulatory Advantages
It has been a long-standing debate in the crypto industry whether tokens should be considered securities. Often tokens are used for fundraising through ICOs or private sales to VCs. On the other hand, many would contend that certain tokens are created for specific DApp usage only and are therefore more like in-game virtual currencies (think Clash of Clans gems). The problem is often tokens are issued for both fundraising and user usage. ERC20NonDilutive enables the issuance of highly inflationary tokens dedicated for user usage while offering the possibility of fundraising through a preferred stock sale. It could be possible that regulators might be favorable to such dual schemes. Inflationary tokens would be distributed for free to users in an unregulated manner with no pretense of investment value. Additional tokens, combined with inflation protection shares (aka preferred stock) would be sold to investors in a regulated manner.

## Example DApp Issuance: Clash of Tribes
### The Concept
Clash of Tribes is a DApp in which users build their crypto village and compete in fighting battles and gathering resources. The in-game currency is ERC-20 tribal crystals (CST). Crystals can be earned by playing the game: improving your village, PvP raids, and completing achievements. With regards to village production and achievements, new crystals are minted periodically as players progress. Crystals can also be purchased through the in-game store or freely traded peer-to-peer.

Initial users do not wish to purchase any crystals. In fact, many users play the game without ever purchasing any. It's often more dedicated users, who reach Tribal Hall level 6 and above, who end up purchasing and spending more crystals to speed up their village's development. The Clash of Tribes developers estimate that it costs around **1000 CST** to on-board a new user to the point where they are self-sufficient and can enjoy the game's mechanics. Beyond that point, users more or less break-even on average (they spend as many CST as they create) and only competitive players who continually invest in buying more CST can truly upgrade their Tribal Hall.

### Investing in the crypto village economy
The Clash of Tribes developer team is looking to raise funding through an initial private sales of tokens. While investors love the gaming concept, their main concern is that if they invest in CST tokens, adoption of Clash of Tribes by users might actually hurt their investment. Indeed new users lead to additional token expenditure which increases the token supply and dilutes investors' share. 

One proposed solution is to simply set a fixed supply, and dedicate some funds for a user onboarding subsidy. 1 billion CST will be issued split 33/33/33 between founders, investors, and new user onboarding fund. The developers believe this is not the best solution as they do not know if 333M CST will be enough (or too much) for jumpstarting the Clash of Tribes economy. They do not know how many and how quickly their DApp will attract users. Furthermore, once the on-boarding fund is fully spent, how will Clash of Tribes onboard new users? With an estimate of 1000 CST per-user, 333M CST would imply a cap of 333k users on-boarded. The reality could be way more or less. Is the 1000 CST estimate even accurate?

### ERC20NonDilutive Issuance Phases
#### Phase 0
The developers propose using an ERC20NonDilutive scheme. CST will be split 33/33/33 between founders, investors, and users. However, the unknown here is the "users" component. The founders set the initial CST supply to 0.  They set the common share to 33, and issue 66 preferred share ERC721 NFTs (33 to founders, 33 to investors). These NFTs are not tokens and have no use cases beyond guaranteeing dilution protection for their holders. That is, founders will always be given 33/99 of the token supply (investors as well).

Summary Phase 0:
- Token: 0 CST
- Inflation Protection: 33 common, 66 preferred

#### Phase 1
Finally, the token minting can begin. For the early beta, founders decide to only mint 1 million CST. At the 1000 CST/user estimate, this can only onboard 1000 users. This is enough for a small beta community but they will have to issue more in the long-term. Since founders and investors hold inflation protection, additional tokens are also minted.
- 1 million minted with 33 common -> 30303 / share
- -> 2 million minted for 66 preferred

When requesting to mint 1 million tokens, these tokens are minted for the "common" pool. Inflation protection holders also need tokens to maintain their ratio. In this case, 2 million is minted for the preferred pool of investors and founders. Note that in a private sale scenario, Phase 0 and Phase 1 would likely be back to back instantly. We just separate the two here for clarity.

Summary Phase 1:
- Token: 3 million CST (1m subsidy, 1m founders, 1m investors)
- Inflation Protection: 33 common, 66 preferred

#### Phase 2
After some development and a successful beta launch, Clash of Tribes is ready to expand its user base to 100,000 users. At this point, the token minting is automated dynamically based on the game's components. On average, user signup unlocks 100 CST, achievements unlock 400 CST, and a village cumulatively produces 500 CST. Assuming tokens are minted only for user onboarding, a total of 100M CST will have to have been minted. Founders and investors are still inflation-protected however, so issuing an additional 99M subsidy will also mint tokens for those parties.

Summary Phase 2:
- Token: 300 million CST (100m subsidy, 100m founders, 100m investors)
- Inflation Protection: 33 common, 66 preferred

#### Phase 3
Investors and founders have sold off some of their tokens on the open market. Most sold tokens are simply used by users in the DApp. They now collectively only own 60 million of the 300 million supply (20%). They decide that they only need 20% inflation protection to maintain their stake. Burning 9 common stock and 60 preferred NFTs enables such a ratio.

Summary Phase 3:
- Token: 300 million CST (240m market, 30m founders, 30m investors)
- Inflation Protection: 24 common, 6 preferred

#### Dynamic Token Minting
In this short example, we present a very simplified minting schedule with only 3 phases. The real power of this model comes from its flexibility. One could imagine 10s if not 100s of phases of perpetual token minting. In fact, provided Clash of Tribes keeps onboarding new users, it would be a good strategy to keep increasing user onboarding funds as needed. This perpetual token minting could come at the cost of nominal token value for users (if an incremental user is worth less than CST inflation), but investors remain protected regardless of this.

Inflation protected holders do not care about the value of 1 token but rather about the aggregate network value that is reflected through the total market cap of the token. This is because their share of the total token supply remains unchanged regardless of nominal token supply (unless if they sell). If the token reaches a final supply cap, inflation protection no longer has any value, but while a subsidy is needed, it guarantees that value holders maintain their proportional share. 