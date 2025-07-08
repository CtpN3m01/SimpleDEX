// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDEX {
    // Variables
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    uint256 public reserveA;
    uint256 public reserveB;
    address public owner;


    // EVENTS
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);

    event SwapAforB(address indexed user, uint256 amountAIn, uint256 amountBOut);

    event SwapBforA(address indexed user, uint256 amountBIn, uint256 amountAOut);

    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);


    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        owner = msg.sender;
    }

    
    // Funtions
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(msg.sender == owner, "Solo el owner puede aportar liquidez");
        require(amountA > 0 && amountB > 0, "Montos deben ser > 0");

        // Si no es el primer aporte, exigir proporción constante
        if (reserveA > 0 || reserveB > 0) {
            require(reserveA * amountB == reserveB * amountA, "Desproporcion en aporte");
        }

        // Transferir tokens desde el owner al pool
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Fallo transferFrom A");
        require(tokenB.transferFrom(msg.sender, address(this), amountB), "Fallo transferFrom B");

        // Actualizar reservas (saldos dentro del contrato)
        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "La cantidad A a intercambiar debe ser > 0");
        require(reserveA > 0 && reserveB > 0, "Pool sin liquidez");

        // Transferir TokenA del usuario al pool
        require(tokenA.transferFrom(msg.sender, address(this), amountAIn), "Fallo al recibir TokenA");

        // Calcular TokenB a enviar usando la formula del producto constante
        uint256 amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);
        require(amountBOut > 0, "El intercambio resultaria en 0 TokenB");

        // Transferir TokenB al usuario
        require(tokenB.transfer(msg.sender, amountBOut), "Fallo al enviar TokenB");

        // Actualizar reservas internas
        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit SwapAforB(msg.sender, amountAIn, amountBOut);
    }

    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "La cantidad B a intercambiar debe ser > 0");
        require(reserveA > 0 && reserveB > 0, "Pool sin liquidez");

        require(tokenB.transferFrom(msg.sender, address(this), amountBIn), "Fallo al recibir TokenB");

        uint256 amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);
        require(amountAOut > 0, "El intercambio resultaria en 0 TokenA");

        require(tokenA.transfer(msg.sender, amountAOut), "Fallo al enviar TokenA");

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit SwapBforA(msg.sender, amountBIn, amountAOut);
    }

    function removeLiquidity(uint256 amountA, uint256 amountB) external {
        require(msg.sender == owner, "Solo el owner puede retirar liquidez");
        require(amountA > 0 && amountB > 0, "Montos deben ser > 0");
        require(amountA <= reserveA && amountB <= reserveB, "No hay suficientes reservas");
        require(reserveA * amountB == reserveB * amountA, "Debe retirar en proporci\u00f3n equivalente");

        // Transferir tokens de la pool al owner
        require(tokenA.transfer(msg.sender, amountA), "Fallo al retirar TokenA");
        require(tokenB.transfer(msg.sender, amountB), "Fallo al retirar TokenB");

        // Actualizar reservas
        reserveA -= amountA;
        reserveB -= amountB;

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    function getPrice(address _token) external view returns (uint256 price) {
        require(reserveA > 0 && reserveB > 0, "Pool sin liquidez");

        if (_token == address(tokenA)) {
            // Precio de 1 TokenA en términos de TokenB
            price = (reserveB * 1e18) / reserveA;
        } else if (_token == address(tokenB)) {
            // Precio de 1 TokenB en términos de TokenA
            price = (reserveA * 1e18) / reserveB;
        } else {
            revert("Token no soportado");
        }
    }

}