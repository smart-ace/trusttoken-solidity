// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @title FinancialOpportunity
 * @dev Interface for third parties to implement financial opportunities
 *
 * -- Overview --
 * The goal of this contract is to allow anyone to create an opportunity
 * to earn interest on TUSD. deposit() "mints" yTUSD whcih is redeemable
 * for some amount of TUSD.
 * TUSD is a compliant stablecoin, therefore we do not allow transfers of
 * yTUSD, thus there are no transfer functions.
 *
 * -- tokenValue() --
 * This function returns the value in TUSD of 1 yTUSD
 * This value should never decrease.
 *
 * -- TUSD vs yTUSD --
 * yTUSD represents a value which is redeemable for some amount of TUSD.
 * This value is also a "share" of the pool interest. So as interest is earned
 * through the pooled TUSD, the value of yTUSD increases
 * Think of yTUSD like cTUSD (Compound Tokens), where cTokens are minted and increase
 * in value as interest is accrued.
 *
 * -- Assumptions --
 * - tokenValue can never decrease
 * - total TUSD owed to depositors = tokenValue() * totalSupply()
 */
interface FinancialOpportunity {
    /**
     * @dev Returns total supply of yTUSD in this contract
     *
     * @return total supply of yTUSD in this contract
     **/
    function totalSupply() external view returns (uint256);

    /**
     * @dev Exchange rate between TUSD and yTUSD
     *
     * tokenValue should never decrease
     *
     * @return TUSD / yTUSD price ratio
     */
    function tokenValue() external view returns (uint256);

    /**
     * @dev deposits TrueUSD and returns yTUSD minted
     *
     * We can think of deposit as a minting function which
     * will increase totalSupply of yTUSD based on the deposit
     *
     * @param amount amount in TUSD to deposit
     * @return yTUSD minted from this deposit
     */
    function deposit(uint256 amount) external returns (uint256);

    /**
     * @dev Redeem yTUSD for TUSD and withdraw to account
     *
     * This function should use tokenValue to calculate
     * how much TUSD is owed. This function should burn yTUSD
     * after redemption
     *
     * This function must return value in TUSD
     *
     * @param amount amount in TUSD to withdraw from finOp
     * @return TUSD amount returned from this transaction
     */
    function redeem(uint256 amount) external returns (uint256);
}
