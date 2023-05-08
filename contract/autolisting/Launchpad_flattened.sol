
// File: interfaces/IVirtualLock.sol


pragma solidity ^0.8.2;

interface IVirtualLock {
    function lock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external payable returns (uint256 lockId);

    function vestingLock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 tgeDate,
        uint256 tgeBps,
        uint256 cycle,
        uint256 cycleBps,
        string memory description
    ) external payable returns (uint256 lockId);

    function multipleVestingLock(
        address[] calldata owners,
        uint256[] calldata amounts,
        address token,
        bool isLpToken,
        uint256 tgeDate,
        uint256 tgeBps,
        uint256 cycle,
        uint256 cycleBps,
        string memory description
    ) external payable returns (uint256[] memory);

    function unlock(uint256 lockId) external;

    function editLock(
        uint256 lockId,
        uint256 newAmount,
        uint256 newUnlockDate
    ) external;
}

// File: structs/LaunchpadStructs.sol


pragma solidity ^0.8.2;

library LaunchpadStructs {
    struct LaunchpadInfo {
        address icoToken; // token address for which presale is created
        address feeToken; // which token will be used for fee. i.e. BUSD, USDT or USDC
        uint256 softCap; // min amount this project wants to collect
        uint256 hardCap; // max amount this project wants to collect
        uint256 presaleRate; // how much ico tokens equal to 1 feeToken
        uint256 minInvest; // minimum limit of a user investment
        uint256 maxInvest; // maximum limit of a user against all the investments
        uint256 startTime; // from which time launchpad will start 
        uint256 endTime; //  at which time launchpad will end
        uint256 whitelistPool; //0 public, 1 whitelist, 2 public anti bot 
                    // Anti-Bot System: With this option you can control who can contribute to the pool. 
                    // Only Users who hold a minimum amount of token you suggest would be able to contribute
        uint256 poolType; //0 burn, 1 refund
    }

    struct ClaimInfo {
        uint256 cliffVesting; //First gap release after listing (minutes)
        uint256 lockAfterCliffVesting; //second gap release after cliff (minutes)
        uint256 firstReleasePercent; // percent of tokens to be released first time.
        uint256 vestingPeriodEachCycle; // time of each cycle after first release
        uint256 tokenReleaseEachCycle; // percentage of tokens to be released on completion of each cycle.
    }


    struct DexInfo {
        bool manualListing; // true -> manualListing(after end of launchpad owner can claim all the collected amount and can manually list on any dex)
                            // false -> autoListing (after end of launchpad liquidity will be added automatically at the time of finalizing the launchpad.)
        address routerAddress; // router address of DEX in case of auto listing
        address factoryAddress; // factory address in case of auto listing
        uint256 listingPrice; // how much tokens will be added for liquidity against one feeToken in case of auto listing
        uint256 listingPercent;// 1=> 10000 (how much percentage of raised feeTokens will be added for liquidity in case of auto listing)
        uint256 lpLockTime; // how much time liquidity will be locked. time will be taken in the form of days.
    }


    struct LaunchpadReturnInfo {
        uint256 softCap; 
        uint256 hardCap;
        uint256 startTime;
        uint256 endTime;
        uint256 state; // state of Launchpad. whether it is actived / finalized / cancelled (1 / 2 / 3 respectively)
        uint256 raisedAmount; // total amount raised yet.
        uint256 balance; // how much tokens are in the account of launchpad smart contract
        address feeToken; 
        uint256 listingTime; // time on which user can claim tokens or time on which liquidity is added.
        uint256 whitelistPool; // status of pool. whether it is public / whitelisted / public anti bot (0 public, 1 whitelist, 2 public anti bot)
        // address holdingToken; // this will be used in case of anti bot mechanism
        // uint256 holdingTokenAmount; // this address will also be used in anti-bot mechanism.
                                // for further detail of anti-bot mechanism see the comments of launchpadInfo structure.
        
        // social links
        string logoURL;
        string description;
        string websiteURL;
        string facebookURL;
        string twitterURL;
        string githubURL;
        string telegramURL;
        string instagramURL;
        string discordURL;
        string redditURL;
    }

    struct OwnerZoneInfo { // this structure is designed to show owner's informations
        bool isOwner; // caller is owner or not
        uint256 whitelistPool; // whether pool is public / whitelisted / anti-bot (0 / 1 / 2 respectively)
        bool canFinalize; // owner can finalized the launchpad or not at this stage.
        bool canCancel; // owner can cancel the launchpad at this stage or not.
                        // NOTE: for further details see getOwnerZoneInfo() function implemented in Launchpad contract
    }

    struct FeeSystem {
        // initFee is commented out because init fee functionality is implemented in deployeLaunchpad by named flatFee.
        // uint256 initFee; // initial fee to create a launchpad. this fee will be transferred to the owner's account at each launchpad creation.
        uint256 raisedFeePercent; // how much percent of collected BNB will be transferred to to the fee collector A/C at the time of finalizing launchpad.
        uint256 raisedTokenFeePercent; // how much percent of collected feeToken will be transferred to the fee collector address at the time of finalizing launchpad.
        uint256 penaltyFee; // how much fee will be dedected on emergency withdrawl in case of both scenarios i.e. BNB / feeToken
    }

    struct SettingAccount {
        address deployer;
        // address signer; // this is used for permit. But we don't want to use this. That is why it is commented out
        address superAccount; // address that will be set by the launchpad owner and it will have power on all the launchpads.
        address payable fundAddress; // address which will receive all kind of collected BNB or tokens.
        address virtualLock; // contract address implementing lock mechanism
    }

    struct TeamVestingInfo {
        uint256 teamTotalVestingTokens; // how much tokens are being invested in presale
        uint256 teamCliffVesting; //First token release after listing (minutes)
        uint256 teamFirstReleasePercent; // how much percentage of tokens will be released first time.
        uint256 teamVestingPeriodEachCycle; // tokens release time limit for each cycle after first time.
        uint256 teamTokenReleaseEachCycle; // percentage of tokens to be released in each cycle.
    }

    struct CalculateTokenInput {
        address feeToken; // against which token presale is created. i.e. against BNB or BUSD or any other ERC20 token.
        uint256 presaleRate; // how much icotokens will be equal to 1 fee Token. i.e. 1 BNB = 100 BL Tokens
        uint256 hardCap; // maximum how much BNB or Fee tokens we want from presale.
        uint256 raisedTokenFeePercent; // in case of feetoken is BUSD or any other ERC20token, how much fee will be deducted from raised BUSD or other ERC20Token 
        uint256 raisedFeePercent; // in case of feeToken is BNB, how much percent will be deducted from raised BNBs and will be transfered to the system. 
        uint256 listingPercent; // in case of autolisting, how much liquidity of raised BNB or Fee tokens will be added.
        uint256 listingPrice; // how much ico tokens will be equal to 1 fee token at the time of liqudity. 
                              // in other words, how much liquidity of icoTokens will be added against 1 feeToken. i.e. 1 BNB = 50 Bl Tokens
    }


    struct SocialLinks {
        string logoURL;
        string description;
        string websiteURL;
        string facebookURL;
        string twitterURL;
        string githubURL;
        string telegramURL;
        string instagramURL;
        string discordURL;
        string redditURL;
    }
}




// File: @openzeppelin/contracts/utils/structs/EnumerableSet.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: interfaces/IVirtualERC20.sol




pragma solidity ^0.8.2;

interface IVirtualERC20 is IERC20 {
   function decimals() external view returns (uint8);
}
// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: Launchpad/Launchpad.sol


pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/access/Ownable.sol";










contract Launchpad is Pausable {
    //using SafeMath for uint256;
    using SafeERC20 for IVirtualERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private whiteListUsers;
    EnumerableSet.AddressSet private superAccounts;
    EnumerableSet.AddressSet private whiteListBuyers;


    // mapping(address => bool) public whiteListUsers;
    // mapping(address => bool) public superAccounts;

    address public launchpadOwner;

    modifier onlyLaunchpadOwner() {
        require(msg.sender == launchpadOwner, "launchpad: Only owner");
        _;
    }

    modifier onlyWhiteListUser() {
        require(whiteListUsers.contains(msg.sender), "launchpad: Only whiteListUsers");
        _;
    }

    modifier onlySuperAccount() {
        require(superAccounts.contains(msg.sender), "launchpad: Only Super");
        _;
    }

    modifier onlyRunningPool() {
        require(state == 1, "launchpad: Not available pool");
        _;
    }

    // function adminWhiteListUsers(address _user, bool _whiteList) public onlySuperAccount {
    //     whiteListUsers[_user] = _whiteList;
    // }

    function addWhiteListUsers(address[] memory _user) public onlyWhiteListUser {
        for (uint i = 0; i < _user.length; i++) {
            whiteListUsers.add(_user[i]);
        }
    }


    function removeWhiteListUsers(address[] memory _user) public onlyWhiteListUser {
        for (uint i = 0; i < _user.length; i++) {
            whiteListUsers.remove(_user[i]);
        }
    }

    function listOfWhiteListUsers() public view returns(address[] memory) {
        return whiteListUsers.values();
    }


    function _check(address _tokenA, address _tokenB, address _routerAddress, address _factoryAddress) internal view returns (bool) {
        address pair;
        IUniswapV2Router02 routerObj = IUniswapV2Router02(_routerAddress);
        IUniswapV2Factory factoryObj = IUniswapV2Factory(_factoryAddress);

        if (_tokenB == address(0)) {
            pair = factoryObj.getPair(address(_tokenA), routerObj.WETH());
        } else {
            pair = factoryObj.getPair(address(_tokenA), address(_tokenB));
        }
        if (pair == address(0)) {
            return true;
        }
        return IVirtualERC20(pair).totalSupply() == 0;
    }

    // function to check that pair is created or not yet for the given token.
    function check() external view returns (bool) {
        return _check(address(icoToken), feeToken, routerAddress, factoryAddress);
    }

    IVirtualERC20 public icoToken;
    address public feeToken; //BUSD, BNB
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public presaleRate; // 1BNB or BUSD ~ presaleRate
    uint256 public minInvest;
    uint256 public maxInvest;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public poolType; //0 burn, 1 refund
    uint256 public whitelistPool;  //0 public, 1 whitelist, 2 public anti bot
    // address public holdingToken;
    // uint256 public holdingTokenAmount;

    // contribute vesting
    uint256 public cliffVesting; //First gap release after listing (minutes)
    uint256 public lockAfterCliffVesting; //second gap release after cliff (minutes)
    uint256 public firstReleasePercent; // 0 is not vesting
    uint256 public vestingPeriodEachCycle; //0 is not vesting
    uint256 public tokenReleaseEachCycle; //percent: 0 is not vesting

    //team vesting
    uint256 public teamTotalVestingTokens; // if > 0, lock
    uint256 public teamCliffVesting; //First gap release after listing (minutes)
    uint256 public teamFirstReleasePercent; // 0 is not vesting
    uint256 public teamVestingPeriodEachCycle; // 0 is not vesting
    uint256 public teamTokenReleaseEachCycle; //percent: 0 is not vesting



    uint256 public listingTime; // 

    uint256 public state; // 1 running||available, 2 finalize, 3 cancel
    uint256 public raisedAmount; // 1 running, 2 cancel
    // address public signer;
    uint256 public constant ZOOM = 10_000;
    uint256 public penaltyFee = 1000; // 10%

    // dex
    bool public manualListing;
    address public factoryAddress;
    address public routerAddress;
    uint256 public listingPrice;
    uint256 public listingPercent; //1 => 10000
    uint256 public lpLockTime; //seconds

    // social information
    string public logoURL;
    string public description;
    string public websiteURL;
    string public facebookURL;
    string public twitterURL;
    string public githubURL;
    string public telegramURL;
    string public instagramURL;
    string public discordURL;
    string public redditURL;

    // lock
    IVirtualLock public virtualLock;
    uint256 public lpLockId;
    uint256 public teamLockId;

    // fee
    uint256 public raisedFeePercent; //BNB With Raised Amount
    uint256 public raisedTokenFeePercent;

    // raised
    address payable public fundAddress;
    uint256 public totalSoldTokens;

    address public deadAddress = address(0x0000dead);
    uint256 public maxLiquidity = 0;

    // structure to hold the investment details of a specific user.
    struct JoinInfo {
        uint256 totalInvestment;
        uint256 claimedTokens;
        uint256 totalTokens;
        bool refund;
    }

    mapping(address => JoinInfo) public joinInfos; // mapping to store join information against specific user
    EnumerableSet.AddressSet private _joinedUsers; // set of joined users



    event Invest(address investor, uint value, uint tokens);
    event Buy(uint256 indexed _saleId, uint256 indexed _quantity, uint256 indexed _price, address _buyer, address _seller);
    event UpdateSaleQuantity(uint256 indexed _saleId, address indexed _seller, uint256 indexed _quantity, uint256 _status);
    event UpdateSalePrice(uint256 indexed _saleId, address indexed _seller, uint256 indexed _price);
    event CancelListed(uint256 indexed _saleId, address indexed _receiver);
    event List(uint indexed _saleId, uint256 indexed _price, uint256 indexed _quantity, address _owner, uint256 _tokenId, uint256 status);
    event TokenClaimed(address _address, uint256 tokensClaimed);


    function setFundAddress(address payable _fundAddress) public onlySuperAccount {
        fundAddress = _fundAddress;
    }

    // function setSigner(address _signer) public onlySuperAccount {
    //     signer = _signer;
    // }

    function setPenaltyFee(uint256 _penaltyFee) public onlySuperAccount {
        penaltyFee = _penaltyFee;
    }


    function setDex(address _factory, address _router) public onlySuperAccount {
        factoryAddress = _factory;
        routerAddress = _router;
    }

    constructor(LaunchpadStructs.LaunchpadInfo memory info, LaunchpadStructs.ClaimInfo memory userClaimInfo, LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,LaunchpadStructs.DexInfo memory dexInfo, LaunchpadStructs.FeeSystem memory feeInfo, LaunchpadStructs.SettingAccount memory settingAccount, LaunchpadStructs.SocialLinks memory socialLinks, uint256 _maxLP) {
        initialize(info, userClaimInfo, teamVestingInfo, dexInfo, feeInfo, settingAccount, socialLinks, _maxLP);
    }

    function initialize (LaunchpadStructs.LaunchpadInfo memory info, LaunchpadStructs.ClaimInfo memory userClaimInfo, LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,LaunchpadStructs.DexInfo memory dexInfo, LaunchpadStructs.FeeSystem memory feeInfo, LaunchpadStructs.SettingAccount memory settingAccount, LaunchpadStructs.SocialLinks memory socialLinks, uint256 _maxLP) 
    public 
    {
        require(info.icoToken != address(0), 'launchpad: TOKEN');
        require(info.presaleRate > 0, 'launchpad: PRESALE');
        require(info.softCap < info.hardCap, 'launchpad: CAP');
        require(info.startTime < info.endTime, 'launchpad: TIME');
        require(info.minInvest < info.maxInvest, 'launchpad: INVEST');
        require(dexInfo.listingPercent <= ZOOM, 'launchpad: LISTING');
        require(userClaimInfo.firstReleasePercent + userClaimInfo.tokenReleaseEachCycle <= ZOOM , 'launchpad: VESTING');
        require(teamVestingInfo.teamFirstReleasePercent + teamVestingInfo.teamTokenReleaseEachCycle <= ZOOM, 'launchpad: Invalid team vst');
        // @dev: if there is only one router, then there is no need to check the following condition.
        require(_check(info.icoToken, info.feeToken, dexInfo.routerAddress, dexInfo.factoryAddress), 'launchpad: LP Added!'); // pair should not be created yet. if already added then there will be error in autolisting case.


        // initialize data of info structure.
        maxLiquidity = _maxLP;
        icoToken = IVirtualERC20(info.icoToken);
        feeToken = info.feeToken;
        softCap = info.softCap;
        hardCap = info.hardCap;
        presaleRate = info.presaleRate;
        minInvest = info.minInvest;
        maxInvest = info.maxInvest;
        startTime = info.startTime;
        endTime = info.endTime;
        whitelistPool = info.whitelistPool;
        poolType = info.poolType;

        // initialize data of userClaimInfo structure.
        cliffVesting = userClaimInfo.cliffVesting;
        lockAfterCliffVesting = userClaimInfo.lockAfterCliffVesting;
        firstReleasePercent = userClaimInfo.firstReleasePercent;
        vestingPeriodEachCycle = userClaimInfo.vestingPeriodEachCycle;
        tokenReleaseEachCycle = userClaimInfo.tokenReleaseEachCycle;

        // initialize data of teamVestingInfo structure if vesting option is selected. 
        teamTotalVestingTokens = teamVestingInfo.teamTotalVestingTokens;
        if (teamTotalVestingTokens > 0) {
            require(teamVestingInfo.teamFirstReleasePercent > 0 &&
            teamVestingInfo.teamVestingPeriodEachCycle > 0 &&
            teamVestingInfo.teamTokenReleaseEachCycle > 0 &&
                teamVestingInfo.teamFirstReleasePercent + teamVestingInfo.teamTokenReleaseEachCycle <= ZOOM,"launchpad: Invalid teamvestinginfo");
            teamCliffVesting = teamVestingInfo.teamCliffVesting;
            teamFirstReleasePercent = teamVestingInfo.teamFirstReleasePercent;
            teamVestingPeriodEachCycle = teamVestingInfo.teamVestingPeriodEachCycle;
            teamTokenReleaseEachCycle = teamVestingInfo.teamTokenReleaseEachCycle;
        }



        manualListing = dexInfo.manualListing;

        // if autolisting option is selected, then initialize dex info.
        if (!manualListing) {
            // this should be first time to create pair of selected tokens.
            require(_check(info.icoToken, info.feeToken, dexInfo.routerAddress, dexInfo.factoryAddress), 'launchpad: LP Added!');
            routerAddress = dexInfo.routerAddress;
            factoryAddress = dexInfo.factoryAddress;
            listingPrice = dexInfo.listingPrice;
            listingPercent = dexInfo.listingPercent;
            lpLockTime = dexInfo.lpLockTime;
        }


        // initialize feeInfo structure
        raisedFeePercent = feeInfo.raisedFeePercent;
        raisedTokenFeePercent = feeInfo.raisedTokenFeePercent;
        penaltyFee = feeInfo.penaltyFee;


        // initialize social links
        logoURL = socialLinks.logoURL;
        description = socialLinks.description;
        websiteURL = socialLinks.websiteURL;
        facebookURL = socialLinks.facebookURL;
        twitterURL = socialLinks.twitterURL;
        githubURL = socialLinks.githubURL;
        telegramURL = socialLinks.telegramURL;
        instagramURL = socialLinks.instagramURL;
        discordURL = socialLinks.discordURL;
        redditURL = socialLinks.redditURL;


        state = 1; // initialize state variable to mention that presale is active, not finalized or not cancelled yet.
        
        // assign powers of ownersship to deployer (owner), superAccount
        whiteListUsers.add(settingAccount.deployer);
        whiteListUsers.add(settingAccount.superAccount);
        superAccounts.add(settingAccount.superAccount);

        // signer = settingAccount.signer;
        fundAddress = settingAccount.fundAddress;

        // transfer ownership from deployLaunchpad address to deployer address.
        launchpadOwner = settingAccount.deployer;

        // initialize Lock contract address for later locking of tokens.
        virtualLock = IVirtualLock(settingAccount.virtualLock);
    }

    // calculate how much tokens of icoToken a user will receive by entering amount of fee tokens or BNB.
    function calculateUserTotalTokens(uint256 _amount) private view returns (uint256) {
        uint256 feeTokenDecimals = 18;
        if (feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(feeToken).decimals();
        }
        return _amount*(presaleRate)/(10 ** feeTokenDecimals);
    }

    // function to set whitelist buyers
    // only whitelist user is authorized.
    function setWhitelistBuyers(address[] memory _buyers) public onlyWhiteListUser {
        for (uint i = 0; i < _buyers.length; i++) {
            whiteListBuyers.add(_buyers[i]);
         }
    }

    // function to remove whiteList buyers
    // only whitelist user is authorized
    function removeWhitelistBuyers(address[] memory _buyers) public onlyWhiteListUser {
        for (uint i = 0; i < _buyers.length; i++) {
            whiteListBuyers.remove(_buyers[i]);
         }
    }

    // return number of whitelist buyers.
    function allAllocationCount() public view returns (uint256) {
        return whiteListBuyers.length();
    }

    // returns all the addresses of whitelistBuyers by passing start and end limit.
    function getAllocations(uint256 start, uint256 end) 
        external
        view
        returns(address[] memory ) 
        
    {
        require(end > start && end <= allAllocationCount(), "launchpad: Invalid");
        address[] memory allocations = new address[](end - start);
        uint count = 0;
        for (uint256 i = start; i < end; i++) {
            allocations[count] = whiteListBuyers.at(i); 
            count++ ;
        }
        return allocations;
    }



    // function to contribute in the pool for any user.
    // i.e. user will use this function to purchase the ico tokens of pool by entering BNB of fee token
    // function contribute(uint256 _amount, bytes calldata _sig) external payable whenNotPaused onlyRunningPool {
    function contribute(uint256 _amount) external payable whenNotPaused onlyRunningPool {
        require(startTime <= block.timestamp && endTime >= block.timestamp, 'launchpad: Invalid time');
        if (whitelistPool == 1) {
            require(whiteListBuyers.contains(_msgSender()), "launchpad: You are not in whitelist");
            // bytes32 message = prefixed(keccak256(abi.encodePacked(
            //         _msgSender(),
            //         address(this)
            //     )));
            // require(recoverSigner(message, _sig) == signer, 'not in wl');
        } 
        // else if (whitelistPool == 2) {
        //     require(IVirtualERC20(holdingToken).balanceOf(_msgSender()) >= holdingTokenAmount, 'launchpad: Insufficient holding');
        // }
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(joinInfo.totalInvestment+(_amount) >= minInvest && joinInfo.totalInvestment+(_amount) <= maxInvest, 'launchpad: Invalid amount');
        require(raisedAmount+(_amount) <= hardCap, 'launchpad: Meet hard cap');


        joinInfo.totalInvestment = joinInfo.totalInvestment+(_amount);

        uint256 newTotalSoldTokens = calculateUserTotalTokens(_amount);
        totalSoldTokens = totalSoldTokens+(newTotalSoldTokens);
        joinInfo.totalTokens = joinInfo.totalTokens+(newTotalSoldTokens);
        joinInfo.refund = false;

        raisedAmount = raisedAmount+(_amount);
        _joinedUsers.add(_msgSender());


        if (feeToken == address(0)) {
            require(msg.value >= _amount, 'launchpad: Invalid Amount');
        } else {
            IVirtualERC20 feeTokenErc20 = IVirtualERC20(feeToken);
            feeTokenErc20.safeTransferFrom(_msgSender(), address(this), _amount);
        }

    }


    // function to cancel launchap.
    // Restriction: 1. only whitelist user is authorized.   2. only running pool can be cancelled.
    function cancelLaunchpad() external onlyWhiteListUser onlyRunningPool {
        state = 3;
    }

    // function to set claim time for raised funds.
    // Can only be called when launchpad will be in running state.
    function setClaimTime(uint256 _listingTime) external onlyWhiteListUser {
        require(state == 2 && _listingTime > 0, "launchpad: TIME");
        listingTime = _listingTime;
    }

    // function to set launchpad whitelist status.
    // 0 for public, 1 for whitelist.
    function setWhitelistPool(uint256 _wlPool) external onlyWhiteListUser {
        require(_wlPool <= 1, "Lanchpad: setWhitelistPool");

        whitelistPool = _wlPool; // 0 for public, 1 for whitelist
    }

    // @dev: this function is commented out because it has public anti-bot. Same function is edited above by removin public-anti bot mechanism.
    // function setWhitelistPool(uint256 _wlPool, address _holdingToken, uint256 _amount) external onlyWhiteListUser {
    //     require(_wlPool < 2 ||
    //         (_wlPool == 2 && _holdingToken != address(0) && IVirtualERC20(_holdingToken).totalSupply() > 0 && _amount > 0), 'launchpad: Invalid setting');
    //     holdingToken = _holdingToken;
    //     holdingTokenAmount = _amount;
    //     whitelistPool = _wlPool;
    // }

    // function to edit launchpad information
    // whitelist user can only edit social links
    // no other information can be changed
    function editLaunchpad(LaunchpadStructs.SocialLinks memory socialLinks) external onlyWhiteListUser onlyRunningPool {
        logoURL = socialLinks.logoURL;
        description = socialLinks.description;
        websiteURL = socialLinks.websiteURL;
        facebookURL = socialLinks.facebookURL;
        twitterURL = socialLinks.twitterURL;
        githubURL = socialLinks.githubURL;
        telegramURL = socialLinks.telegramURL;
        instagramURL = socialLinks.instagramURL;
        discordURL = socialLinks.discordURL;
        redditURL = socialLinks.redditURL;
    }


    function finalizeLaunchpad() external onlyWhiteListUser onlyRunningPool {
        require(block.timestamp > startTime, 'launchpad: Not start');

        if (block.timestamp < endTime) {
            require(raisedAmount >= hardCap, 'launchpad: Cant finalize');
        }
        if (block.timestamp >= endTime) {
            require(raisedAmount >= softCap, 'launchpad: Not meet soft cap');
        }
        state = 2;

        uint256 feeTokenDecimals = 18;
        if (feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(feeToken).decimals();
        }

        uint256 totalRaisedFeeTokens = raisedAmount*(presaleRate)*(raisedTokenFeePercent)/(10 ** feeTokenDecimals)/(ZOOM);

        uint256 totalRaisedFee = raisedAmount*(raisedFeePercent)/(ZOOM);

        uint256 totalFeeTokensToAddLP = (raisedAmount-(totalRaisedFee))*(listingPercent)/(ZOOM);
        // 0 if listingPercent = 0
        uint256 totalFeeTokensToOwner = raisedAmount-(totalRaisedFee)-(totalFeeTokensToAddLP);
        uint256 icoTokenToAddLP = totalFeeTokensToAddLP*(listingPrice)/(10 ** feeTokenDecimals);

        uint256 icoLaunchpadBalance = icoToken.balanceOf(address(this));
        uint256 totalRefundOrBurnTokens = icoLaunchpadBalance-(icoTokenToAddLP)-(totalSoldTokens)-(totalRaisedFeeTokens);

        if (totalRaisedFeeTokens > 0) {
            icoToken.safeTransfer(fundAddress, totalRaisedFeeTokens);
        }

        if (totalRefundOrBurnTokens > 0) {
            if (poolType == 0) {
                icoToken.safeTransfer(deadAddress, totalRefundOrBurnTokens);
            } else {
                icoToken.safeTransfer(launchpadOwner, totalRefundOrBurnTokens);
            }
        }


        if (feeToken == address(0)) {
            if (totalFeeTokensToOwner > 0) {
                payable(launchpadOwner).transfer(totalFeeTokensToOwner);
            }
            if (totalRaisedFee > 0) {
                payable(fundAddress).transfer(totalRaisedFee);
            }

        } else {
            if (totalFeeTokensToOwner > 0) {
                IVirtualERC20(feeToken).safeTransfer(launchpadOwner, totalFeeTokensToOwner);
            }
            if (totalRaisedFee > 0) {
                IVirtualERC20(feeToken).safeTransfer(fundAddress, totalRaisedFee);
            }
        }


        if (!manualListing) {
            maxLiquidity = icoTokenToAddLP;
            listingTime = block.timestamp;
            icoToken.approve(routerAddress, icoTokenToAddLP);
            require(_check(address(icoToken), feeToken, routerAddress, factoryAddress), 'launchpad: LP Added!');
            IUniswapV2Router02 routerObj = IUniswapV2Router02(routerAddress);
            IUniswapV2Factory factoryObj = IUniswapV2Factory(factoryAddress);
            address pair;
            uint liquidity;

            if (feeToken == address(0)) {
                (,, liquidity) = routerObj.addLiquidityETH{value : totalFeeTokensToAddLP}(
                    address(icoToken),
                    icoTokenToAddLP,
                    0,
                    0,
                    address(this),
                    block.timestamp);
                pair = factoryObj.getPair(address(icoToken), routerObj.WETH());
            } else {

                IVirtualERC20(feeToken).approve(routerAddress, totalFeeTokensToAddLP);
                (,, liquidity) = routerObj.addLiquidity(
                    address(icoToken),
                    address(feeToken),
                    icoTokenToAddLP,
                    totalFeeTokensToAddLP,
                    0,
                    0,
                    address(this),
                    block.timestamp
                );
                pair = factoryObj.getPair(address(icoToken), address(feeToken));
            }
            require(pair != address(0), 'launchpad: Invalid pair');
            require(liquidity > 0, 'launchpad: Invalid Liquidity!');
            if (lpLockTime > 0) {
                IVirtualERC20(pair).approve(address(virtualLock), liquidity);
                uint256 unlockDate = block.timestamp + lpLockTime;
                lpLockId = virtualLock.lock(launchpadOwner, pair, true, liquidity, unlockDate, 'launchpad: LP');

            } else {
                IVirtualERC20(pair).safeTransfer(launchpadOwner, liquidity);
            }

            if (teamTotalVestingTokens > 0) {
            icoToken.approve(address(virtualLock), teamTotalVestingTokens);
            teamLockId = virtualLock.vestingLock(
                launchpadOwner,
                address(icoToken),
                false,
                teamTotalVestingTokens,
                listingTime+(teamCliffVesting),
                teamFirstReleasePercent,
                teamVestingPeriodEachCycle,
                teamTokenReleaseEachCycle,
                'launchpad: TEAM');
            }

        }
    }

    // this function will be used to claim cancelled tokens.
    // it will be used only after the cancellation of launchpad.
    function claimCanceledTokens() external onlyWhiteListUser {
        require(state == 3, 'launchpad: Not cancel');
        uint256 balance = icoToken.balanceOf(address(this));
        require(balance > 0, "launchpad: Claimed");
        if (balance > 0) {
            icoToken.safeTransfer(_msgSender(), balance);
        }
    }

    // super account can withdraw any token or BNB from the contract at any time.
    // Although this is wrong, but to avoid vastage of assets, this function is implemented.
    // owner of launchpad will call the super account to perform this action.
    function emergencyWithdrawPool(address _token, uint256 _amount) external onlySuperAccount {
        require(_amount > 0, 'launchpad: Invalid amount');
        if (_token == address(0)) {
            payable(_msgSender()).transfer(_amount);
        }
        else {
            IVirtualERC20 token = IVirtualERC20(_token);
            token.safeTransfer(_msgSender(), _amount);
        }
    }

    // anyone can withdraw his contribution at any time by paying 
    function withdrawContribute() external whenNotPaused {
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require((state == 3) || (raisedAmount < softCap && block.timestamp > endTime));
        require(joinInfo.refund == false, 'launchpad: Refunded');
        require(joinInfo.totalInvestment > 0, 'launchpad: Not Invest');

        uint256 totalWithdraw = joinInfo.totalInvestment;
        joinInfo.refund = true;
        joinInfo.totalTokens = 0;
        joinInfo.totalInvestment = 0;

        raisedAmount = raisedAmount-(totalWithdraw);

        totalSoldTokens = totalSoldTokens-(joinInfo.totalTokens);

        _joinedUsers.remove(_msgSender());

        if (feeToken == address(0)) {
            require(address(this).balance > 0, 'launchpad: Insufficient blc');
            payable(_msgSender()).transfer(totalWithdraw);
        } else {
            IVirtualERC20 feeTokenErc20 = IVirtualERC20(feeToken);

            require(feeTokenErc20.balanceOf(address(this)) >= totalWithdraw, 'launchpad: Insufficient Balance');
            feeTokenErc20.safeTransfer(_msgSender(), totalWithdraw);
        }
    }

    function emergencyWithdrawContribute() external whenNotPaused onlyRunningPool {
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(startTime <= block.timestamp && endTime >= block.timestamp, 'launchpad: Invalid time');
        require(joinInfo.refund == false, 'launchpad: Refunded');
        require(joinInfo.totalInvestment > 0, 'launchpad: Not contribute');

        uint256 penalty = joinInfo.totalInvestment*(penaltyFee)/(ZOOM);
        uint256 refundTokens = joinInfo.totalInvestment-(penalty);
        raisedAmount = raisedAmount-(joinInfo.totalInvestment);
        totalSoldTokens = totalSoldTokens-(joinInfo.totalTokens);


        joinInfo.refund = true;
        joinInfo.totalTokens = 0;
        joinInfo.totalInvestment = 0;
        _joinedUsers.remove(_msgSender());

        require(refundTokens > 0, 'launchpad: Invalid rf amount');

        if (feeToken == address(0)) {
            if (refundTokens > 0) {
                payable(_msgSender()).transfer(refundTokens);
            }

            if (penalty > 0) {
                payable(fundAddress).transfer(penalty);
            }

        } else {
            IVirtualERC20 feeTokenErc20 = IVirtualERC20(feeToken);
            if (refundTokens > 0) {
                feeTokenErc20.safeTransfer(_msgSender(), refundTokens);
            }

            if (penalty > 0) {
                feeTokenErc20.safeTransfer(fundAddress, penalty);
            }
        }
    }


    function claimTokens() external whenNotPaused {
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(joinInfo.claimedTokens < joinInfo.totalTokens, "launchpad: Claimed");
        require(state == 2, "launchpad: Not finalize");
        require(joinInfo.refund == false, "launchpad: Refunded!");


        uint256 claimableTokens = _getUserClaimAble(joinInfo);
        require(claimableTokens > 0, 'launchpad: Zero token');

        uint256 claimedTokens = joinInfo.claimedTokens+(claimableTokens);
        joinInfo.claimedTokens = claimedTokens;
        icoToken.safeTransfer(_msgSender(), claimableTokens);
    }

    function getUserClaimAble(address _sender) external view returns (uint256) {
        JoinInfo storage joinInfo = joinInfos[_sender];
        return _getUserClaimAble(joinInfo);
    }

    function _getUserClaimAble(JoinInfo memory joinInfo)
    internal
    view
    returns (uint256)
    {
        uint256 claimableTokens = 0;
        if (state != 2 || joinInfo.totalTokens == 0 || joinInfo.refund == true || joinInfo.claimedTokens >= joinInfo.totalTokens || listingTime == 0 || block.timestamp < listingTime + cliffVesting) {
            return claimableTokens;
        }
        uint256 currentTotal = 0;
        if (firstReleasePercent == ZOOM) {
            currentTotal = joinInfo.totalTokens;
        } else {
            uint256 tgeReleaseAmount = joinInfo.totalTokens*(firstReleasePercent)/(ZOOM);
            uint256 cycleReleaseAmount = joinInfo.totalTokens*(tokenReleaseEachCycle)/(ZOOM);
            uint256 time = 0;

            uint256 firstVestingTime = listingTime + cliffVesting + lockAfterCliffVesting;
            if (lockAfterCliffVesting == 0) {
                firstVestingTime  = firstVestingTime + vestingPeriodEachCycle;
            }

            if (block.timestamp >= firstVestingTime) {
                time = ((block.timestamp-(firstVestingTime))/(vestingPeriodEachCycle))+(1);
            }

            currentTotal = (time*(cycleReleaseAmount))+(tgeReleaseAmount);
            if (currentTotal > joinInfo.totalTokens) {
                currentTotal = joinInfo.totalTokens;
            }
        }

        claimableTokens = currentTotal-(joinInfo.claimedTokens);
        return claimableTokens;
    }


    function getLaunchpadInfo() external view returns (LaunchpadStructs.LaunchpadReturnInfo memory) {
        uint256 balance = icoToken.balanceOf(address(this));

        LaunchpadStructs.LaunchpadReturnInfo memory result;
        result.softCap = softCap;
        result.hardCap = hardCap;
        result.startTime = startTime;
        result.endTime = endTime;
        result.state = state;
        result.raisedAmount = raisedAmount;
        result.balance = balance;
        result.feeToken = feeToken;
        result.listingTime = listingTime;
        result.whitelistPool = whitelistPool;
        // result.holdingToken = holdingToken;
        // result.holdingTokenAmount = holdingTokenAmount;
        result.logoURL = logoURL;
        result.description = description;
        result.websiteURL = websiteURL;
        result.facebookURL = facebookURL;
        result.twitterURL = twitterURL;
        result.githubURL = githubURL;
        result.telegramURL = telegramURL;
        result.instagramURL = instagramURL;
        result.discordURL = discordURL;
        result.redditURL = redditURL;

        return result;
    }

    function getOwnerZoneInfo(address _user) external view returns (LaunchpadStructs.OwnerZoneInfo memory) {
        LaunchpadStructs.OwnerZoneInfo memory result;
        bool isOwner = _user == launchpadOwner;
        if (!isOwner) {
            return result;
        }
        result.isOwner = isOwner;
        result.whitelistPool = whitelistPool;

        // if false => true,
        result.canCancel = state == 1;
        result.canFinalize = state == 1 &&
        ((block.timestamp < endTime && raisedAmount >= hardCap) ||
        (block.timestamp >= endTime && raisedAmount >= softCap));
        return result;
    }


    function getJoinedUsers()
    external
    view
    returns (address[] memory)
    {
        uint256 start = 0;
        uint256 end = _joinedUsers.length();
        if (end == 0) {
            return new address[](0);
        }
        uint256 length = end - start;
        address[] memory result = new address[](length);
        uint256 index = 0;
        for (uint256 i = start; i < end; i++) {
            result[index] = _joinedUsers.at(i);
            index++;
        }
        return result;
    }


    function pause() public onlyWhiteListUser whenNotPaused {
        _pause();
    }

    function unpause() public onlyWhiteListUser whenPaused {
        _unpause();
    }

    // function prefixed(bytes32 hash) internal pure returns (bytes32) {
    //     return
    //     keccak256(
    //         abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    //     );
    // }

    // function recoverSigner(bytes32 message, bytes memory sig)
    // internal
    // pure
    // returns (address)
    // {
    //     uint8 v;
    //     bytes32 r;
    //     bytes32 s;

    //     (v, r, s) = splitSignature(sig);

    //     return ecrecover(message, v, r, s);
    // }

    // function splitSignature(bytes memory sig)
    // internal
    // pure
    // returns (
    //     uint8,
    //     bytes32,
    //     bytes32
    // )
    // {
    //     require(sig.length == 65);

    //     bytes32 r;
    //     bytes32 s;
    //     uint8 v;

    //     assembly {
    //     // first 32 bytes, after the length prefix
    //         r := mload(add(sig, 32))
    //     // second 32 bytes
    //         s := mload(add(sig, 64))
    //     // final byte (first byte of the next 32 bytes)
    //         v := byte(0, mload(add(sig, 96)))
    //     }

    //     return (v, r, s);
    // }

}


