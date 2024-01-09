# FXY Staking Smart Contract

# Overview

The FXY Staking Smart Contract is designed to allow users to stake FXY 
tokens for different durations and earn interest based on the staking period. 
This smart contract enables users to deposit FXY tokens, lock them for a specific duration, 
and receive interest upon maturity. The contract also includes features 
for penalty calculations in case of pre-mature withdrawals.

# Features
* Staking FXY tokens for various durations.
* Dynamic interest calculation based on staking duration and base APY.
* Penalty mechanism for pre-mature withdrawals.
* Owner-managed parameters, such as APY, minimum FXY requirement, and pre-mature withdrawal penalty.

# Contract Structure

# ERC20Burnable

The smart contract uses the ERC20Burnable interface for interacting with the FXY token. 
This allows the contract to transfer and burn FXY tokens as needed.

# Ownable

The smart contract is Ownable, meaning that the owner (deployer) has special 
privileges, such as updating contract parameters and managing the penalty percentage.

# Structs

* DurationStakeInfo: Contains information about each staking duration, including the 
multiplier and whether the duration is valid.

* DepositInfo: Represents details about each deposit made by a user, including staking duration, start time, maturity time, staked FXY amount, and maturity amount.

* UserTokenDeposits: Stores a list of all deposits made by a user.

# Events

* Staked: Fired when a user successfully stakes FXY tokens, providing information about 
the staking user, staked amount, timestamp, and maturity time.

* Withdrawn: Fired when a user successfully withdraws staked FXY tokens upon maturity.

* PreWithdrawn: Fired when a user withdraws FXY tokens pre-maturely, providing information 
about the user and the withdrawn amount.

# Functions

# Constructor

* Initializes the contract with parameters such as the FXY token address, fee receiver address, 
minimum FXY requirement, pre-mature withdrawal penalty, base APY, and staking durations 
with corresponding multipliers.

# calculateMaturityAmount

* Utility function to calculate the maturity amount based on the staked FXY amount 
and staking duration.

# stake

* Allows users to stake FXY tokens for a specified duration, updating relevant contract 
and user state.

# withdraw

* Allows users to withdraw staked FXY tokens based on the specified deposit index, 
considering maturity and applying penalties for pre-mature withdrawals.

# updatePreMaturePenalty

*Allows the owner to update the pre-mature withdrawal penalty percentage.

# updateAPY

Allows the owner to update the base Annual Percentage Yield (APY) for interest calculations.

# updateMinMLD

Allows the owner to update the minimum FXY amount required for staking.

# Deployment

To deploy the FXY Staking Smart Contract, follow these steps:

1. Deploy the FXY token contract.
2. Deploy the FXY Staking Smart Contract, providing the FXY token address, fee receiver address, 
minimum FXY requirement, pre-mature withdrawal penalty, base APY, and staking durations with 
corresponding multipliers.
