const { ethers } = require("ethers");
const JSBI = require("jsbi");
const { TickMath, FullMath } = require("@uniswap/v3-sdk");
require("dotenv").config();

const INFURA_URL_MAINNET = process.env.INFURA_URL_MAINNET;

const baseToken = ""; // token address
const quoteToken = ""; // token address

const provider = new ethers.providers.JsonRpcProvider(INFURA_URL_MAINNET);

async function main(
  baseToken,
  quoteToken,
  inputAmount,
  currentTick,
  baseTokenDecimals,
  quoteTokenDecimals
) {
  // code
  const sqrtRatioX96 = TickMath.getSqrtRatioAtTick(currentTick);
  const ratioX192 = JSBI.multiply(sqrtRatioX96, sqrtRatioX96);

  const baseAmount = JSBI.BigInt(inputAmount * 10 ** baseTokenDecimals);

  const shift = JSBI.leftShift(JSBI.BigInt(1), JSBI.BigInt(192));

  quoteAmount = FullMath.mulDivRoundingUp(ratioX192, baseAmount, shift);
  console.log(quoteAmount.toString() / 10 ** quoteTokenDecimals);
}

main(
  baseToken,
  quoteToken,
  1,
  // slot0(),
  8,
  18
);
