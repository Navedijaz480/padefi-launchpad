// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Clones.sol";
import "../structs/LaunchpadStructs.sol";
import "../interfaces/ILaunchpad.sol";
import "../interfaces/IVirtualERC20.sol";

contract LaunchpadFactory is Ownable {
    using SafeMath for uint256;
    using Address for address payable;
    uint256 public constant ZOOM = 10000;

    uint256 public flatFee; // fee that will be calculated on each launchpad creation
    // address public signer;
    address public superAccount;
    address public virtualLock;
    address payable public fundAddress; // address that will calculate all types of funds.
    address public implementation; // implementation of the launchpad. This will be used to clone the launchpad

    ILaunchpad[] public allLaunchpads; // array that will store all launchpads created yet.
    mapping (address => ILaunchpad[]) private allLaunchpadsOf; // mapping to store all launchpads created by the user.

    event NewLaunchpad(address indexed launchpad);

    constructor(
        // address _signer,
        address _superAccount,
        address _virtualLock,
        address payable _fundAddress,
        address _implementation
    ) {
        // require(_signer != address(0) && _signer != address(this), "signer");
        require(
            _virtualLock != address(0) && _virtualLock != address(this),
            "LauchpadFactory: virtualLock"
        );
        require(
            _superAccount != address(0) && _superAccount != address(this),
            "LauchpadFactory: superAccount"
        );
        require(
            _fundAddress != address(0) && _fundAddress != address(this),
            "LauchpadFactory: fundAddress"
        );
        // signer = _signer;
        superAccount = _superAccount;
        fundAddress = _fundAddress;
        virtualLock = _virtualLock;
        implementation = _implementation;
    }

    // function setSigner(address _signer) public onlyOwner {
    //     signer = _signer;
    // }


    function setSuperAccount(address _superAccount) public onlyOwner {
        superAccount = _superAccount;
    }

    function setVirtualLock(address _virtualLock) public onlyOwner {
        virtualLock = _virtualLock;
    }

    function setFundAddress(address payable _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function setFlatFee(uint256 _flatFee) public onlyOwner {
        flatFee = _flatFee;
    }

    function setImplementations(address _implementation) public onlyOwner {
        implementation = _implementation;
    }

    // if deployer send BNBs more than decided fee, then excessive fee will be returned back to the deployer.
    function refundExcessiveFee() internal {
        uint256 refund = msg.value - (flatFee);
        if (refund > 0) {
            payable(msg.sender).sendValue(refund);
        }
    }

    // this function is used to calcluate how many tokens deployer should have to approve to Deploy Launchpad to create a new launchpad.
    function calculateTokens(
        LaunchpadStructs.CalculateTokenInput memory input
    ) public view returns (uint256, uint256) {
        uint256 feeTokenDecimals = 18;
        if (input.feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(input.feeToken).decimals();
        }

        uint256 totalPresaleTokens = (input.presaleRate.mul((input.hardCap))).div(10 ** feeTokenDecimals);

        uint256 totalFeeTokens = (totalPresaleTokens.mul(input.raisedTokenFeePercent)).div(ZOOM);

        uint256 totalRaisedFee = (input.hardCap.mul(input.raisedFeePercent)).div(ZOOM);
        uint256 netCap = input.hardCap.sub(totalRaisedFee);
        uint256 totalFeeTokensToAddLP = (netCap.mul(input.listingPercent)).div(ZOOM);

        uint256 totalLiquidityTokens = (totalFeeTokensToAddLP.mul(input.listingPrice)).div(10 ** feeTokenDecimals);

        uint256 result = totalPresaleTokens.add(totalFeeTokens).add(totalLiquidityTokens);
        return (result, totalLiquidityTokens);
    }

    // main function that will make clones on each time a deployer will want to create a new launchpad.
    function deployLaunchpad(
        LaunchpadStructs.LaunchpadInfo memory info,
        LaunchpadStructs.ClaimInfo memory claimInfo,
        LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,
        LaunchpadStructs.DexInfo memory dexInfo,
        LaunchpadStructs.FeeSystem memory feeInfo,
        LaunchpadStructs.SocialLinks memory socialLinks
    ) external payable {
        require(
            // signer != address(0) &&
                superAccount != address(0) &&
                fundAddress != address(0),
            "LauchpadFactory: Can not create launchpad now!"
        );
        require(msg.value >= flatFee, "LauchpadFactory: Not enough fee!");

        // refund excessive fee paid by the user
        if(msg.value > flatFee){
            refundExcessiveFee();
        }

        LaunchpadStructs.SettingAccount memory settingAccount = LaunchpadStructs
            .SettingAccount(
                _msgSender(),
                // signer,
                superAccount,
                payable(fundAddress),
                virtualLock
            );

        IVirtualERC20 icoToken = IVirtualERC20(info.icoToken);
        uint256 feeTokenDecimals = 18;
        if (info.feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(info.feeToken).decimals();
        }

        LaunchpadStructs.CalculateTokenInput memory input = LaunchpadStructs
            .CalculateTokenInput(
                info.feeToken,
                info.presaleRate,
                info.hardCap,
                feeInfo.raisedTokenFeePercent,
                feeInfo.raisedFeePercent,
                dexInfo.listingPercent,
                dexInfo.listingPrice
            );

        uint256 totalTokens;
        uint256 maxLP;

        (totalTokens, maxLP) = calculateTokens(input);

        // clone implementation
        address launchpad = Clones.clone(implementation);
        // initialize new cloned implementation
        ILaunchpad(launchpad).initialize(
            info,
            claimInfo,
            teamVestingInfo,
            dexInfo,
            feeInfo,
            settingAccount,
            socialLinks,
            maxLP
        );
        // LaunchpadV2 launchpad = new LaunchpadV2(info, claimInfo, teamVestingInfo, dexInfo, feeInfo, settingAccount, maxLP);

        if (msg.value > 0) {
            payable(fundAddress).transfer(msg.value);
        }

        if (totalTokens > 0) {
            IERC20 icoTokenErc20 = IERC20(info.icoToken);

            require(
                icoTokenErc20.balanceOf(_msgSender()) >= totalTokens,
                "LauchpadFactory: Insufficient Balance"
            );
            require(
                icoTokenErc20.allowance(_msgSender(), address(this)) >=
                    totalTokens,
                "LauchpadFactory: Insufficient Allowance"
            );

            require(
                icoToken.transferFrom(
                    _msgSender(),
                    address(launchpad),
                    totalTokens
                ),
                "LauchpadFactory: transfer failed"
            );
        }

        allLaunchpads.push(ILaunchpad(launchpad)); 
        allLaunchpadsOf[msg.sender].push(ILaunchpad(launchpad));


        emit NewLaunchpad(address(launchpad));
    }

    // total launchpads created yet on the platform
    function totalLaunchpads() external view returns (ILaunchpad[] memory launchpads){
        return allLaunchpads;
    }

    // total launchpads by user. This will be used for myContribution section
    function totalLaunchpadsByUser(address _user) external view returns (ILaunchpad[] memory launchpadsByUser){
        return allLaunchpadsOf[_user];
    }

}
