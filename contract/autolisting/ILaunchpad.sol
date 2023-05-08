// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../structs/LaunchpadStructs.sol";

interface ILaunchpad {
    function initialize(
        LaunchpadStructs.LaunchpadInfo memory info,
        LaunchpadStructs.ClaimInfo memory userClaimInfo,
        LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,
        LaunchpadStructs.DexInfo memory dexInfo,
        LaunchpadStructs.FeeSystem memory feeInfo,
        LaunchpadStructs.SettingAccount memory settingAccount,
        LaunchpadStructs.SocialLinks memory socialLinks,
        uint256 _maxLP
    ) external;

    function getLaunchpadInfo()
        external
        view
        returns (LaunchpadStructs.LaunchpadReturnInfo memory);

    function getOwnerZoneInfo(
        address _user
    ) external view returns (LaunchpadStructs.OwnerZoneInfo memory);

    function getJoinedUsers()
    external
    view
    returns (address[] memory);
}
