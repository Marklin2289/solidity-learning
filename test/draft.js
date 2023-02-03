function encode(text0, text1){
    return abi.encode(text0, text1);
}

function encodePacked(text0, text1) {
    return abi.encodePacked(text0,text1);
}

console.log(encode("AAA","BBB"));
console.log("==================");
console.log(encodePacked("AAA","BBB"));