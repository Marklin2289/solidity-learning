// function encode(text0, text1){
//     return abi.encode(text0, text1);
// }

// function encodePacked(text0, text1) {
//     return abi.encodePacked(text0,text1);
// }

// console.log(encode("AAA","BBB"));
// console.log("==================");
// console.log(encodePacked("AAA","BBB"));

function _sqrt(y){
    let x;
    let z;
    if (y > 3) {
        z = y;
        x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
    // console.log(z);
    return z;
}
console.log("y = 5, share is                  : " + _sqrt(5));
console.log("y = 500, share is                : " + _sqrt(500));
console.log("y = 50000, share is              : " + _sqrt(50000));
console.log("y = 5000000, share is            : " + _sqrt(5000000));
console.log("y = 500000000, share is          : " + _sqrt(500000000));
console.log("y = 500000000000000000, share is : " + _sqrt(500000000000000000));