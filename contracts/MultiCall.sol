// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestMultiCall {
    function test(uint _i) external view returns (uint, uint) {
        return (_i, block.timestamp);
    }
    function fun1() external view returns(uint, uint) {
        return (1, block.timestamp);
    }
    function fun2() external view returns(uint, uint) {
        return (2, block.timestamp);
    }
    function getTestData(uint _i) external pure returns(bytes memory){
        return abi.encodeWithSelector(this.test.selector, _i);
    }
    function getData1() external pure returns(bytes memory){
        // abi.encodeWithSignature("func1()");
        return abi.encodeWithSelector(this.fun1.selector);
    }
    function getData2() external pure returns(bytes memory){
        return abi.encodeWithSelector(this.fun2.selector);
    }
}
contract MultiCall {
    function multiCall(
        address[] calldata targets,
        bytes[] calldata data
    ) external view returns (bytes[] memory) {
        bytes[] memory results = new bytes[](data.length);
        // For each address in targets use staticcall to call targets[i] passing data[i].
        
        // Fail if any call to address in targets fails
        // Save the result in results bytes array.
        // Return all the results stored in results.
        // Fail if targets.length differs from data.length.
        require(targets.length == data.length, "Different Length");
        
        for(uint i = 0; i<targets.length; i++){
            (bool success, bytes memory response) = targets[i].staticcall(data[i]);
            require(success, "fail");
            
            results[i] = response;
        }
        
        return results;
    }
}