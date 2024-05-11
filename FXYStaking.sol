// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract FXYStaking is Ownable {
    ERC20Burnable public immutable fxyToken;

    address public feeReceiver;
    uint256 public minFXY;
    uint256 public baseAPY;
    uint256 public preMatureFXYPenalty;
    uint256 public totalFXYStakedByUsers;
    uint256 public totalFXYInYieldPool;
    uint256[] public stakeDurationInSec;

    struct DurationStakeInfo {
        uint256 multiplier;
        bool valid;
    }

    mapping(uint256 => DurationStakeInfo) public durationwiseStake;

    struct DepositInfo {
        uint256 durationStaked;
        uint256 start;
        uint256 maturity;
        uint256 fxyStaked;
        uint256 maturityAmount;
    }

    struct UserTokenDeposits {
        DepositInfo[] deposits;
    }

    mapping(address => UserTokenDeposits) private userDeposits;
    mapping(address => uint256) public userTotalDeposits;

    event Staked(
        address indexed user,
        uint256 indexed fxyStaked,
        uint256 indexed stakedAt,
        uint256 maturityTime
    );
    event Withdrawn(address indexed _of, uint256 indexed _amount);
    event PreWithdrawn(address indexed _of, uint256 indexed _amount);
    event FeeReceiverUpdated(address indexed newFeeReceiver);

    modifier incorrectPercentage(uint256 _feesPercentage) {
        require(_feesPercentage < 90, "Very High fees");
        _;
    }

    constructor(
        ERC20Burnable _fxyToken,
        address _feeReceiver,
        uint256 _minFXY,
        uint256 _preMatureFXYPenalty,
        uint256 _baseAPY,
        uint256[] memory _stakeDurationInDays,
        uint256[] memory _multiplier
    ) {
        require(_feeReceiver != address(0), "Invalid admin address");
        require(
            _stakeDurationInDays.length == _multiplier.length,
            "Arrays length mismatch"
        );
        require(_preMatureFXYPenalty < 90, "Very High fees");

        feeReceiver = _feeReceiver;
        fxyToken = _fxyToken;
        baseAPY = _baseAPY;
        minFXY = _minFXY;
        preMatureFXYPenalty = _preMatureFXYPenalty;

        for (uint256 i = 0; i < _stakeDurationInDays.length; i++) {
            uint256 durationInSec = _stakeDurationInDays[i] * 1 days;
            stakeDurationInSec.push(durationInSec);

            durationwiseStake[durationInSec].valid = true;
            durationwiseStake[durationInSec].multiplier = _multiplier[i];
        }
    }

    function calculateMaturityAmount(
        uint256 _stakedFXY,
        uint256 _stakeDurationInSec
    ) public view returns (uint256) {
        uint256 multiplier = durationwiseStake[_stakeDurationInSec].multiplier;
        if (multiplier == 0) multiplier = 100;
        // Calculate interest rate per second
        uint256 interestRatePerSecond = ((multiplier * baseAPY * 1e16) /
            (365 days * 100));
        // Calculate total interest
        uint256 totalInterest = (_stakedFXY *
            interestRatePerSecond *
            _stakeDurationInSec) / 1e18;
        // Return total interest plus Principal amount earned
        return totalInterest + _stakedFXY;
    }

    function stake(uint256 _fxyAmount, uint256 _stakeDurationInSec) external {
        require(
            durationwiseStake[_stakeDurationInSec].valid,
            "Invalid Staking Duration"
        );
        require(_fxyAmount >= minFXY, "Insufficient FXY");

        // Check if the contract has enough tokens to pay the yield
        uint256 remainingRewards = fxyToken.balanceOf(address(this)) - totalFXYInYieldPool;
        uint256 maturityAmount = calculateMaturityAmount(
            _fxyAmount,
            _stakeDurationInSec
        );
      
       require(remainingRewards >= maturityAmount, "Insufficient remaining yield in the contract");

        // require(
        //     fxyToken.balanceOf(address(this)) >= maturityAmount,
        //     "Insufficient yield in the contract"
        // );

        totalFXYStakedByUsers += _fxyAmount;
        totalFXYInYieldPool += maturityAmount;

        uint256 maturityTime = block.timestamp + _stakeDurationInSec;
        userDeposits[msg.sender].deposits.push(
            DepositInfo(
                _stakeDurationInSec,
                block.timestamp,
                maturityTime,
                _fxyAmount,
                calculateMaturityAmount(_fxyAmount, _stakeDurationInSec)
            )
        );
        userTotalDeposits[msg.sender] += _fxyAmount;

        fxyToken.transferFrom(msg.sender, address(this), _fxyAmount);

        emit Staked(msg.sender, _fxyAmount, block.timestamp, maturityTime);
    }

    function withdraw(uint256 _index) external {
        address user = msg.sender;

        require(
            _index < userDeposits[user].deposits.length,
            "Invalid Index"
        );
        DepositInfo memory userDepositInfo = userDeposits[user].deposits[_index];

        uint256 fxyStaked = userDepositInfo.fxyStaked;

        totalFXYStakedByUsers -= fxyStaked;
        totalFXYInYieldPool -= userDepositInfo.maturityAmount;

        uint lastIndex = userDeposits[user].deposits.length - 1;
        userDeposits[user].deposits[_index] = userDeposits[user].deposits[
            lastIndex
        ];
        userDeposits[user].deposits.pop();

        if (block.timestamp >= userDepositInfo.maturity) {
            uint256 returnAmount = userDepositInfo.maturityAmount;

            fxyToken.transfer(user, returnAmount);

            emit Withdrawn(user, returnAmount);
        } else if (block.timestamp < userDepositInfo.maturity) {
            uint256 fxyPenalty = (fxyStaked * preMatureFXYPenalty) / 100;
            uint256 withdrawableAmount = fxyStaked - fxyPenalty;

            fxyToken.transfer(user, withdrawableAmount);
            fxyToken.transfer(feeReceiver, fxyPenalty);

            emit PreWithdrawn(user, withdrawableAmount);
        }
    }

    function updatePreMaturePenalty(
        uint256 _penaltyPercentage
    ) external onlyOwner incorrectPercentage(_penaltyPercentage) {
        preMatureFXYPenalty = _penaltyPercentage;
    }

    function updateAPY(uint256 _baseAPY) external onlyOwner {
        baseAPY = _baseAPY;
    }

    function updateMinMLD(uint256 _minFXY) external onlyOwner {
        minFXY = _minFXY;
    }

    function updateFeeReceiver(address _newFeeReceiver) external onlyOwner {
        require(_newFeeReceiver != address(0), "Invalid feeReceiver address");
        feeReceiver = _newFeeReceiver;
        emit FeeReceiverUpdated(_newFeeReceiver);
    }

  function getDepositInfo(address user, uint256 index) external view returns (
    uint256 durationStaked,
    uint256 start,
    uint256 maturity,
    uint256 fxyStaked,
    uint256 maturityAmount
) {
    require(index < userDeposits[user].deposits.length, "Invalid Index");

    DepositInfo memory depositInfo = userDeposits[user].deposits[index];

    return (
        depositInfo.durationStaked,
        depositInfo.start,
        depositInfo.maturity,
        depositInfo.fxyStaked,
        depositInfo.maturityAmount
    );
}
}
