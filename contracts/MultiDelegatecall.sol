// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiDelegatecall {
    error DelegatecallFailed();

    function multiDelegatecall(
        bytes[] memory data
    ) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);

        for (uint i = 0; i < data.length; i++) {
            (bool sent, bytes memory response) = address(this).delegatecall(
                data[i]
            );
            if (!sent) {
                revert DelegatecallFailed();
            }
            results[i] = response;
        }
    }
}

// Why use multi delegatecall? Why not multi call?
// alice -> multi call --- call ---> test (msg.sender = multi call)
// alice -> test --- delegatecall ---> test (msg.sender = alice)
contract TestMultiDelegatecall is MultiDelegatecall {
    event Log(address indexed caller, string func, uint i);

    mapping(address => uint) public balanceOf;

    function func1(uint x, uint y) external {
        // msg.sender = alice
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint) {
        // msg.sender = alice
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    // WARNING: unsafe code when used in combination with multi-delegatecall
    // user can mint multiple times for the price of msg.value
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
        return
            abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegate.func2.selector);
    }

    function getMintData() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegate.mint.selector);
    }
}
