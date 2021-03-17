// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import {Dai, TrueUSD} from "./StableCoins.sol";
import {FinancialOpportunity} from "./FinancialOpportunity.sol";
import {DaiPot, DSRMock} from "./DSR.sol";
import {SwapContract, SwapContractMock} from "./SwapContract.sol";
import "./SafeMath.sol";

/**
 * @title Dai Financial Opportunity
 * @dev Pool TUSD deposits to earn interest using DSR
 *
 * When a user wants to deposit TrueUSD** the contract will exchange 
 * the TUSD for Dai using Uniswap, and then deposit DAI into a DSR.
 *
 * When a user wants to redeem their stake for TrueUSD the contract will 
 * withdraw DAI from a DSR, then swap the DAI for TrueUSD using Uniswap.

 * Implement the 4 functions from FinancialOpportunity in a new contract: 
 * deposit(), redeem(), tokenValue(), and totalSupply(). 
 * 
 * Make sure to read the documentation in FinaicialOpportunity.sol carefully 
 * to make sure you understand the purpose of each of these functions. 
 *
 * Note: the contract mocks are untested and might require modifications!
 *
**/
contract DaiFinancialOpportunity is FinancialOpportunity {
    using SafeMath for uint256;

    SwapContractMock public uniswapRouter;
    DSRMock public pot;

    TrueUSD public trueUSD;
    Dai public dai;

    uint256 public yTUSDSupply;
    mapping(address => uint256) public stakedAmount;

    event Deposited(address indexed from, uint256 amount);
    event Redeemed(address indexed to, uint256 amount);

    constructor(
        address _uniswapRouter,
        address _pot,
        address _trueUSD,
        address _dai
    ) public {
        uniswapRouter = SwapContractMock(_uniswapRouter);
        pot = DSRMock(_pot);
        trueUSD = TrueUSD(_trueUSD);
        dai = Dai(_dai);
    }

    function tokenValue() public view override returns (uint256) {
        /// if we use uniswap we should calculate the amount by using getAmountsOut
        // address[] path = [address(trueUSD), address(dai)];
        // uint256 amountOut = uniswapRouter.getAmountsOut(1e18, path);
        // return amountOut;
        return 1e18; // returns tokenValue in Wei.
    }

    function deposit(uint256 amount) external override returns (uint256) {
        require(amount > 0, "Invalid Amount");
        require(
            trueUSD.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        uint256 yTUSDAmount = amount.mul(tokenValue()).div(1e18);
        //  in uniswap, we should use this function
        //  address[] path = [address(trueUSD), address(dai)];
        //  uniswapRouter.swapExactTokensForTokens(amount, yTUSDAmount, path, address(this), block.timestamp + 1800);

        trueUSD.approve(address(uniswapRouter), amount.add(1e18));
        uniswapRouter.swapTUSDforDAI(amount);

        // Calculate yTUSDAmount using TokenValue()
        dai.approve(address(pot), yTUSDAmount.add(1e18));
        pot.join(yTUSDAmount);

        yTUSDSupply = yTUSDSupply.add(yTUSDAmount);
        stakedAmount[msg.sender] = stakedAmount[msg.sender].add(yTUSDAmount);
        emit Deposited(msg.sender, amount);
    }

    function redeem(uint256 amount) external override returns (uint256) {
        require(amount > 0, "Invalid Amount");
        uint256 yTUSDAmount = amount.mul(tokenValue()).div(1e18);
        require(
            stakedAmount[msg.sender] >= yTUSDAmount,
            "Insufficient staked amount!"
        );
        pot.exit(yTUSDAmount);

        //  in uniswap, we should use this function
        //  address[] path = [address(dai), address(trueUSD)];
        //  uniswapRouter.swapExactTokensForTokens(yTUSDAmount, amount, path, address(this), block.timestamp + 1800);

        uniswapRouter.swapDAIforTUSD(yTUSDAmount);
        require(
            trueUSD.transferFrom(
                address(this),
                msg.sender,
                // trueUSD.balanceOf(address(this))
                amount
            ),
            "Transfer failed"
        );
        yTUSDSupply = yTUSDSupply.sub(yTUSDAmount);
        stakedAmount[msg.sender] = stakedAmount[msg.sender].sub(yTUSDAmount);
        emit Redeemed(msg.sender, amount);
    }

    function totalSupply() external view override returns (uint256) {
        return yTUSDSupply.mul(tokenValue()).div(1e18);
    }
}
