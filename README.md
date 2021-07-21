# Synthetix Wrappr Arb

Contracts for arbitraging Synthetix's Wrappr tokens via Curve. This was inspired by the [`synthetix-link-wrappr`](https://github.com/flashbots/mev-job-board/blob/89e342d5d088059c7c1693ff6c32bf7d19e88b2e/specs/synthetix-link-wrappr.md) MEV job board task.

The contracts are currently only set up to work with `sETH/ETH` but minor adjustements can be made to accomodate any new pair (eg. `sLINK/LINK`). Also, two flash loan options are currently available for taking the arbitrage:

- Aave (due to the high fee that is charged on the flash loaned amount, using it won't probably be successfull)
- dYdX (this is the most efficient, as the fee is only 2 wei)

### Usage

```bash
# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm test
```

The tests depend on mainnet forking, so make sure you have an `.env` file at the root of the repo containing the following:

```bash
ALCHEMY_KEY=
BLOCK_NUMBER=
```

For deterministic results, I set up the block number to be `12562542` (this is exactly the block before [this](https://etherscan.io/tx/0xb561d0e0c6f96ceeea7cec9ab486df719fdd4f4807d45a65ed87687a8e7ee731) arbitrage transaction).

### Todos

- [ ] Mimick the exact results of the above arbitrage transaction
- [ ] Create watcher script that continually checks for arbitrage opportunities
