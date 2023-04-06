// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.19;

import "./PadeFiVesting.sol";
import "./address.sol";

contract PresaleFactoryVesting {
  using Address for address payable;
 

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
    uint256 refund = msg.value-(flatFee);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function create_vesting_contract (
    address  token,
    uint256  totalTokens,
    uint256  firstRelease,// enter percentage 
    uint256  vestingPeriod, //enter in minute 
    uint256  ReleaseEveryCycle //release amount on every cycle //enter percentage 
   
  ) external payable enoughFee returns (address) {
      require(token !=address(0),"enter correct address ");
      require(totalTokens >0 ,"enter token greater than zero");
      require(firstRelease<=100 ,"enter amount in percentage ");
      require(vestingPeriod> block.timestamp ,"enter amount in percentage ");



    refundExcessiveFee();
    PadeFiVesting newToken = new PadeFiVesting(
       token,  totalTokens,   firstRelease,  vestingPeriod,  ReleaseEveryCycle
    );
    emit CreateEvent(address(newToken));
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}