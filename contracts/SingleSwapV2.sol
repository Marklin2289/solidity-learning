// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import and use hardhat/console.sol to debug your contract
// import "hardhat/console.sol";

import "@uniswap/v2-core/contracts/interfaces/IERC20.sol";

// import "./IUniswapV2Router.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract UniswapV2SingleHopSwap {
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    IUniswapV2Router private constant router =
        IUniswapV2Router(UNISWAP_V2_ROUTER);
    IERC20 private constant weth = IERC20(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function swapSingleHopExactAmountIn(
        uint amountIn,
        uint amountOutMin
    ) external {
        // Code
    }

    function swapSingleHopExactAmountOut(
        uint amountOutDesired,
        uint amountInMax
    ) external {
        // Code
    }
}
