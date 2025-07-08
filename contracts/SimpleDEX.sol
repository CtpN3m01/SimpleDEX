// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SimpleDEX
 * @dev A simple decentralized exchange that allows the owner to provide liquidity,
 * users to swap between two ERC20 tokens using the constant product formula (x * y = k),
 * and the owner to withdraw liquidity.
 */
contract SimpleDEX {
    // Token pair managed by the DEX
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    // Internal reserves of TokenA and TokenB
    uint256 public reserveA;
    uint256 public reserveB;

    // Address of the contract owner (liquidity provider)
    address public owner;

    // --- EVENTS ---

    /// @notice Emitted when liquidity is added to the pool
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);

    /// @notice Emitted when a user swaps TokenA for TokenB
    event SwapAforB(address indexed user, uint256 amountAIn, uint256 amountBOut);

    /// @notice Emitted when a user swaps TokenB for TokenA
    event SwapBforA(address indexed user, uint256 amountBIn, uint256 amountAOut);

    /// @notice Emitted when liquidity is removed from the pool
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

    /**
     * @dev Initializes the DEX with the addresses of TokenA and TokenB
     * @param _tokenA Address of TokenA contract
     * @param _tokenB Address of TokenB contract
     */
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    /**
     * @dev Allows the owner to add liquidity to the pool.
     * Requires token amounts to match the current reserve ratio (if not the first deposit).
     * @param amountA Amount of TokenA to deposit
     * @param amountB Amount of TokenB to deposit
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(msg.sender == owner, "Only the owner can add liquidity");
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");

        // Enforce proportional contribution if pool is not empty
        if (reserveA > 0 || reserveB > 0) {
            require(reserveA * amountB == reserveB * amountA, "Unequal value ratio");
        }

        // Transfer tokens from owner to this contract
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "TokenA transfer failed");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "TokenB transfer failed");

        // Update internal reserves
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /**
     * @dev Swaps TokenA for TokenB using the constant product formula.
     * @param amountAIn Amount of TokenA to swap
     */
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be greater than zero");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "TokenA transfer failed");

        // Calculate TokenB output using constant product formula
        uint256 amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);
        require(amountBOut > 0, "Swap would result in zero output");

        require(tokenB.transfer(msg.sender, amountBOut), "TokenB transfer failed");

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit SwapAforB(msg.sender, amountAIn, amountBOut);
    }

    /**
     * @dev Swaps TokenB for TokenA using the constant product formula.
     * @param amountBIn Amount of TokenB to swap
     */
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be greater than zero");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "TokenB transfer failed");

        // Calculate TokenA output using constant product formula
        uint256 amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);
        require(amountAOut > 0, "Swap would result in zero output");

        require(tokenA.transfer(msg.sender, amountAOut), "TokenA transfer failed");

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit SwapBforA(msg.sender, amountBIn, amountAOut);
    }

    /**
     * @dev Allows the owner to remove liquidity from the pool.
     * Requires that the withdrawal maintains the pool's token ratio.
     * @param amountA Amount of TokenA to withdraw
     * @param amountB Amount of TokenB to withdraw
     */
    function removeLiquidity(uint256 amountA, uint256 amountB) external {
        require(msg.sender == owner, "Only the owner can remove liquidity");
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");
        require(amountA <= reserveA && amountB <= reserveB, "Insufficient reserves");
        require(reserveA * amountB == reserveB * amountA, "Withdrawal must preserve ratio");

        require(tokenA.transfer(msg.sender, amountA), "TokenA withdrawal failed");
        require(tokenB.transfer(msg.sender, amountB), "TokenB withdrawal failed");

        reserveA -= amountA;
        reserveB -= amountB;

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /**
     * @dev Returns the current exchange rate of the specified token in terms of the other.
     * The result is scaled by 1e18 to include decimals.
     * @param _token Address of the token to price
     * @return price Scaled price (1 token = `price` units of the other)
     */
    function getPrice(address _token) external view returns (uint256 price) {
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        if (_token == address(tokenA)) {
            // Price of 1 TokenA in terms of TokenB
            price = (reserveB * 1e18) / reserveA;
        } else if (_token == address(tokenB)) {
            // Price of 1 TokenB in terms of TokenA
            price = (reserveA * 1e18) / reserveB;
        } else {
            revert("Unsupported token address");
        }
    }
}
