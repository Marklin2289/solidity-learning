// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Implement ERC20.

// ERC20 is a commonly used token standard with 3 important functions, tranfser, approve and transferFrom.

// transfer - Transfer token from msg.sender to another account
// approve - Approve another account to spend your tokens.
// transferFrom - Approved account can transfer tokens on your behalf
// A common scenario to use approve and transferFrom is the following.

// You approve a contract to spend some of your tokens. 
// Next the contract calls transferFrom to transfer tokens from you into the contract.

// By following the 2 steps above, you avoid the risk of accidentally sending tokens to the wrong address.

// Here is the interface for ERC20
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}
