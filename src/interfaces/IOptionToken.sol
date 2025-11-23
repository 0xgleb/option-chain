// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IOptionToken
 * @notice Interface for option token contracts
 * @dev Minimal interface stub for vault integration. Full implementation in later phase.
 */
interface IOptionToken is IERC20 {
    /**
     * @notice Exercise option tokens to receive underlying (call) or strike payment (put)
     * @param amount Number of option tokens to exercise
     */
    function exercise(uint256 amount) external;

    /**
     * @notice Burn option tokens along with vault shares to reclaim collateral early
     * @param amount Number of tokens to burn
     */
    function burnWithShares(uint256 amount) external;

    /**
     * @notice Get the vault address for this option series
     * @return The vault contract address
     */
    function vault() external view returns (address);

    /**
     * @notice Get the strike price for this option
     * @return The strike price (in quote token units)
     */
    function strike() external view returns (uint256);

    /**
     * @notice Get the expiry timestamp for this option
     * @return The expiry timestamp (Unix seconds)
     */
    function expiry() external view returns (uint256);

    /**
     * @notice Check if this is a call option
     * @return True if call option, false if put option
     */
    function isCall() external view returns (bool);
}
