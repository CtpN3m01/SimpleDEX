# SimpleDEX – Decentralized Token Exchange on Scroll Sepolia

**SimpleDEX** is a minimal decentralized exchange (DEX) built on the Scroll Sepolia testnet. It allows users to swap between two ERC-20 tokens — TokenA and TokenB — using an automated market maker (AMM) model based on the constant product formula:  
> (x + Δx) * (y - Δy) = x * y

## 📦 Deployed Contracts

| Contract     | Address                                                                 |
|--------------|-------------------------------------------------------------------------|
| TokenA       | [`0x729448733C94495Da1C2e350a6621ff9FC3B1672`](https://sepolia.scrollscan.com/address/0x729448733C94495Da1C2e350a6621ff9FC3B1672) |
| TokenB       | [`0xF890dcAD1a702f74eD80F138Ddd12fac4cE51fEE`](https://sepolia.scrollscan.com/address/0xF890dcAD1a702f74eD80F138Ddd12fac4cE51fEE) |
| SimpleDEX    | [`0xBc469da34FE5B238D55e3c9BA3a2d0fF17a59Ac6`](https://sepolia.scrollscan.com/address/0xBc469da34FE5B238D55e3c9BA3a2d0fF17a59Ac6) |

## ⚙️ Features

- ✅ Add liquidity (only owner)
- 🔁 Swap TokenA ↔ TokenB (any user)
- 💧 Remove liquidity (only owner)
- 📈 Get token price based on current pool reserves

## 📚 Smart Contracts Overview

### `TokenA.sol` & `TokenB.sol`

- Standard ERC-20 tokens implemented with OpenZeppelin.
- 18 decimals, mintable in constructor.

### `SimpleDEX.sol`

- Contains the liquidity pool for TokenA and TokenB.
- Uses the constant product formula (x * y = k).
- Key functions:
  - `addLiquidity(uint256 amountA, uint256 amountB)`
  - `swapAforB(uint256 amountAIn)`
  - `swapBforA(uint256 amountBIn)`
  - `removeLiquidity(uint256 amountA, uint256 amountB)`
  - `getPrice(address _token)`

## 🧪 How to Test on Remix

1. Connect to the **Scroll Sepolia** testnet using MetaMask.
2. Deploy or import the contracts using the provided addresses.
3. Interact with the contracts using Remix’s interface:
   - Use `approve()` on TokenA/TokenB before calling swap or addLiquidity.
   - Use `swapAforB()` or `swapBforA()` to perform token swaps.
   - Use `getPrice()` to check the exchange rate.

## 👨‍💻 Owner Permissions

Only the `owner` (contract deployer) can:
- Add or remove liquidity.
- Control initial balances and token supply.

## 🧠 Learning Objectives

This project was built to understand and apply:
- Decentralized finance (DeFi) primitives
- ERC-20 token standards
- AMM logic (constant product formula)
- Solidity contract interactions
- Manual deployment and testing with Remix on Scroll Sepolia

## 📜 License

MIT License
