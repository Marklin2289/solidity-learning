// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CPAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // internal balance of token amount
    uint public reserve0;
    uint public reserve1;

    // total shares
    uint public totalSupply;

    //share per user
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        //takes in two tokens addresses
        token0 = IERC20(_token0);
        token1 = IERC20(_token1); // initial tokens
    }

    // internal _mint
    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount; // share per user increase
        totalSupply += _amount; // total share increase
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount; // share per token decrease
        totalSupply -= _amount; // total share decrease
    }

    function _update(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    // token0 => token1 or token1 => token0
    function swap(
        address _tokenIn,
        uint _amountIn
    ) external returns (uint amountOut) {
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "Invalid token to swap"
        );
        require(_amountIn > 0, "amount must be greater than 0");

        // pull in token in =>
        // First, check token0 or token1:
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);
        // transfer tokenIn into address(this):
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        // calculate token out (inclding fee), fee = 0.3%
        // dy = ydx / (x + dx) : calculate amountOut dy
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee) // dy
        // Transfer token out to msg.sender:
        tokenOut.transfer(msg.sender, amountOut)
        // Update the reserves
        _update(
            token0.balanceOf(address(this)), 
            token1.balanceOf(address(this))
        );

        /*
        How many dy for dx?

        xy = k
        (x + dx)(y - dy) = k
        y - dy = k / (x + dx)
        y - k / (x + dx) = dy
        y - xy / (x + dx) = dy
        (yx + ydx - xy) / (x + dx) = dy
        ydx / (x + dx) = dy
        */
    }

    function addLiquidity( //take in two tokens' amounts
        uint _amount0,
        uint _amount1
    ) external returns (uint shares) { // return shares

        // Pull in token0 and token1
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        // make sure the price of tokens are not changed : dy / dx = y / x : 
        // dy * x = dx * y :
        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "dy / dy != y / x");
        }

        // Mint shares
        // f(x,y) = value of liquidity = sqrt(xy)
        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
        // s = dx / x * T = dy / y * T
            shares = _min(
                // dx / x * T
                (_amount0 * totalSupply) / reserve0,
                // dy / y * T
                (_amount1 * totalSupply) / reserve1
            );
        }
        require(shares > 0, "failed");
        _mint(msg.sender, shares);
        // Update reserves
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );

        /*
        How many dx, dy to add?

        xy = k
        (x + dx)(y + dy) = k'

        No price change, before and after adding liquidity
        x / y = (x + dx) / (y + dy)

        x(y + dy) = y(x + dx)
        x * dy = y * dx

        x / y = dx / dy
        dy = y / x * dx
        */
        /*
        How many shares to mint?

        f(x, y) = value of liquidity
        We will define f(x, y) = sqrt(xy)

        L0 = f(x, y)
        L1 = f(x + dx, y + dy)
        T = total shares
        s = shares to mint

        Total shares should increase proportional to increase in liquidity
        L1 / L0 = (T + s) / T

        L1 * T = L0 * (T + s)

        (L1 - L0) * T / L0 = s 
        */
        /*
        Claim
        (L1 - L0) / L0 = dx / x = dy / y

        Proof
        --- Equation 1 ---
        (L1 - L0) / L0 = (sqrt((x + dx)(y + dy)) - sqrt(xy)) / sqrt(xy)
        
        dx / dy = x / y so replace dy = dx * y / x

        --- Equation 2 ---
        Equation 1 = (sqrt(xy + 2ydx + dx^2 * y / x) - sqrt(xy)) / sqrt(xy)

        Multiply by sqrt(x) / sqrt(x)
        Equation 2 = (sqrt(x^2y + 2xydx + dx^2 * y) - sqrt(x^2y)) / sqrt(x^2y)
                   = (sqrt(y)(sqrt(x^2 + 2xdx + dx^2) - sqrt(x^2)) / (sqrt(y)sqrt(x^2))
        
        sqrt(y) on top and bottom cancels out

        --- Equation 3 ---
        Equation 2 = (sqrt(x^2 + 2xdx + dx^2) - sqrt(x^2)) / (sqrt(x^2)
        = (sqrt((x + dx)^2) - sqrt(x^2)) / sqrt(x^2)  
        = ((x + dx) - x) / x
        = dx / x

        Since dx / dy = x / y,
        dx / x = dy / y

        Finally
        (L1 - L0) / L0 = dx / x = dy / y
        */
    }

    function removeLiquidity(
        uint _shares
    ) external returns (uint amount0, uint amount1) {
        // calculate amount0 and amount1 to withdraw
        // dx, dy = amount of liquidity to remove
        // dx = s / T * x
        // dy = s / T * y
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));
        amount0 = (_shares * bal0) / totalSupply; // dx/x = s/t => s = dx/x * t 
        amount1 = (_shares * bal1) / totalSupply;
        //  Burn shares
        _burn(msg.msg.sender,_shares);
        // Update reserves
        _update(bal0 - amount0, bal1 - amount1);
        // Transfer token0 and token1 to msg.sender
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
        /*
        How many tokens to withdraw?

        Claim
        dx, dy = amount of liquidity to remove
        dx = s / T * x
        dy = s / T * y

        Proof
        Let's find dx, dy such that
        v / L = s / T
        
        where
        v = f(dx, dy) = sqrt(dxdy)
        L = total liquidity = sqrt(xy)
        s = shares
        T = total supply

        --- Equation 1 ---
        v = s / T * L
        sqrt(dxdy) = s / T * sqrt(xy)

        Amount of liquidity to remove must not change price so 
        dx / dy = x / y

        replace dy = dx * y / x
        sqrt(dxdy) = sqrt(dx * dx * y / x) = dx * sqrt(y / x)

        Divide both sides of Equation 1 with sqrt(y / x)
        dx = s / T * sqrt(xy) / sqrt(y / x)
           = s / T * sqrt(x^2) = s / T * x

        Likewise
        dy = s / T * y
        */
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;`
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function _update(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }
}
