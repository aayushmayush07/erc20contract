---

# aayushmayush07-erc20contract

From-scratch ERC-20 built with **Foundry**. `ERC20.sol` uses ERC-6093 custom errors; `AkToken.sol` is the concrete token that mints initial supply to the deployer.

## Structure

```
src/            # ERC20 core, AkToken, Context, interfaces
script/         # Deploy scripts
test/           # Unit & fuzz tests + harness
.github/        # CI (build, fmt, test)
```

## Quickstart

```bash
foundryup
forge build
forge test -vv
forge fmt
anvil
```

## Deploy (example)

```bash
forge script script/DeployAkToken.s.sol:DeployAkToken \
  --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## Interact (Cast)

```bash
# reads
cast call $TOKEN "name()(string)"
cast call $TOKEN "balanceOf(address)(uint256)" 0xYourAddr

# writes
cast send $TOKEN "approve(address,uint256)" 0xSpender 100e18 --private-key $PK
cast send $TOKEN "transfer(address,uint256)" 0xTo 1e18 --private-key $PK
```

## Notes

* Unified `_update` handles transfer/mint/burn.
* Infinite allowance optimization (no decrement at `type(uint256).max`).
* Tests cover events, guards, allowance math, and supply conservation.

**License:** MIT
