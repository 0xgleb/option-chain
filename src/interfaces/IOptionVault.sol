// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

/**
 * @title IOptionVault
 * @notice Interface for option vault contracts managing collateral per option series
 * @dev Extends ERC-4626 with option-specific functionality for exercise and post-expiry claims
 */
interface IOptionVault is IERC4626 {
    /**
     * @notice Deposit checkpoint tracking FIFO assignment
     * @param depositor Address that made the deposit
     * @param amount Amount of collateral deposited
     * @param cumulativeAmount Running total of deposits up to this checkpoint
     * @param collateralToken Address of collateral token (ERC20 or option token)
     * @param claimed Whether this checkpoint has been claimed post-expiry
     */
    struct DepositCheckpoint {
        address depositor;
        uint256 amount;
        uint256 cumulativeAmount;
        address collateralToken;
        bool claimed;
    }

    // ============================================
    // ERRORS
    // ============================================

    /// @notice Thrown when unauthorized account attempts restricted operation
    error VaultUnauthorizedAccount(address account);

    /// @notice Thrown when operation attempted before expiry timestamp
    error VaultNotExpired();

    /// @notice Thrown when operation attempted after expiry timestamp
    error VaultExpired();

    /// @notice Thrown when insufficient collateral available for operation
    error VaultInsufficientCollateral();

    /// @notice Thrown when option collateral doesn't meet constraints
    error VaultInvalidOptionCollateral();

    /// @notice Thrown when recursive exercise depth limit exceeded
    error VaultRecursionDepthExceeded();

    /// @notice Thrown when no claim available for caller
    error VaultNothingToClaim();

    // ============================================
    // EVENTS
    // ============================================

    /**
     * @notice Emitted when option tokens are exercised
     * @param exerciser Address exercising the option
     * @param amount Amount of options exercised
     * @param totalExercised New total exercised amount
     */
    event Exercised(address indexed exerciser, uint256 amount, uint256 totalExercised);

    /**
     * @notice Emitted when writer claims post-expiry entitlement
     * @param writer Address claiming
     * @param strikePayment Amount of strike payment received (if assigned)
     * @param collateralReturned Amount of collateral returned (if unassigned)
     */
    event Claimed(address indexed writer, uint256 strikePayment, uint256 collateralReturned);

    /**
     * @notice Emitted when deposit checkpoint is created
     * @param depositor Address making deposit
     * @param amount Amount deposited
     * @param cumulativeAmount Cumulative total after this deposit
     * @param collateralToken Token used as collateral
     */
    event CheckpointCreated(
        address indexed depositor,
        uint256 amount,
        uint256 cumulativeAmount,
        address indexed collateralToken
    );

    // ============================================
    // EXTERNAL FUNCTIONS
    // ============================================

    /**
     * @notice Withdraw assets for option exercise (restricted to OptionToken contract)
     * @dev Decrements total assets and increments total exercised counter
     * @param assets Amount of assets to withdraw
     * @param receiver Address receiving the assets
     * @param optionToken Address of the option token contract (for validation)
     * @return shares Amount of shares burned (informational)
     */
    function withdrawForExercise(uint256 assets, address receiver, address optionToken) external returns (uint256);

    /**
     * @notice Claim post-expiry entitlement based on FIFO assignment
     * @dev Iterates depositor's checkpoints, calculates assignment, makes batched transfers
     */
    function claim() external;

    /**
     * @notice Increment options outstanding counter when new options minted
     * @param amount Amount of options minted
     */
    function mintOptions(uint256 amount) external;

    /**
     * @notice Decrement options outstanding counter when options burned
     * @param amount Amount of options burned
     */
    function burnOptions(uint256 amount) external;

    // ============================================
    // VIEW FUNCTIONS
    // ============================================

    /**
     * @notice Get total amount of options exercised
     * @return Total exercised amount
     */
    function totalExercised() external view returns (uint256);

    /**
     * @notice Get total options currently outstanding
     * @return Total outstanding options
     */
    function optionsOutstanding() external view returns (uint256);

    /**
     * @notice Get option token contract address
     * @return Address of the option token
     */
    function optionToken() external view returns (address);

    /**
     * @notice Get strike price for this option series
     * @return Strike price in quote token units
     */
    function strike() external view returns (uint256);

    /**
     * @notice Get expiry timestamp for this option series
     * @return Expiry timestamp (Unix seconds)
     */
    function expiry() external view returns (uint256);

    /**
     * @notice Check if this is a call option vault
     * @return True if call option, false if put option
     */
    function isCall() external view returns (bool);

    /**
     * @notice Get quote token address
     * @return Address of the quote token
     */
    function quoteToken() external view returns (address);

    /**
     * @notice Get number of deposit checkpoints for a depositor
     * @param depositor Address to query
     * @return Number of checkpoints
     */
    function getCheckpointCount(address depositor) external view returns (uint256);

    /**
     * @notice Get specific deposit checkpoint for a depositor
     * @param depositor Address to query
     * @param index Checkpoint index
     * @return checkpoint The deposit checkpoint struct
     */
    function getCheckpoint(address depositor, uint256 index) external view returns (DepositCheckpoint memory);
}
