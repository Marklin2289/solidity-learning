// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TestMultiCall {
    function test(uint _i) external pure returns (uint) {
        return _i;
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