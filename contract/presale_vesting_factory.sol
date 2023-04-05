// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.19;

import "./TokensVesting.sol";
// import "./address.sol";

contract PresaleFactoryVesting {
  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  address _owner;
  uint256 public flatFee;

  modifier enoughFee() {
    require(msg.value >= flatFee, "Flat fee");
    _;
  }

  modifier onlyOwner {
    require(msg.sender == _owner, "You are not owner");
    _;
  }

  event CreateEvent(address indexed tokenAddress);

  constructor() {
    feeTo = msg.sender;
    flatFee = 10_000_000 gwei;
    _owner = msg.sender;
  }

  function setFeeTo(address feeReceivingAddress) external onlyOwner {
    feeTo = feeReceivingAddress;
  }

  function setFlatFee(uint256 fee) external onlyOwner {
    flatFee = fee;
  }

  function refundExcessiveFee() internal {
    uint256 refund = msg.value.sub(flatFee);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function create(
   address token, //token address
    address beneficiary, // owner address
     uint256 start,  //start time 
     uint256 duration, //total time 
      uint256 releasesCount, //cycle 
       bool revocable,
        address revoker
  ) external payable enoughFee returns (address) {
    require(beneficiary != address(0), "TokensVesting: beneficiary is the zero address!");
        require(token != address(0), "TokensVesting: token is the zero address!");
        require(revoker != address(0), "TokensVesting: revoker is the zero address!");
        require(duration > 0, "TokensVesting: duration is 0!");
        require(releasesCount > 0, "TokensVesting: releases count is 0!");
        require(start.add(duration) > block.timestamp, "TokensVesting: final time is before current time!");

    refundExcessiveFee();
    TokensVesting newToken = new TokensVesting(
      token, beneficiary, start, duration, releasesCount,
      revocable, revoker
    );
    emit CreateEvent(address(newToken));
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}