// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.19;

import "./PresaleNew.sol";
import "./address.sol";

contract PresaleFactoryNew {
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
    address _sale_token,
    uint256 _token_rate,
    uint256 _raise_min, 
    uint256 _raise_max, 
    uint256 _softcap, 
    uint256 _hardcap,
    bool _whitelist,
    uint256 _presale_start,
    uint256 _presale_end,
    bool _refund
  ) external payable enoughFee returns (address) {
    require(_raise_min < _raise_max, "Raise_max must more than raise_min");
    require(_hardcap > _softcap, "Hardcap must more than softcap");
    require(_softcap > _hardcap/2, "Softcap must more than hardcap * 50%");
    require(_presale_end > _presale_start, "End date cannot be earlier than start date");
    refundExcessiveFee();
    PresaleNew newToken = new PresaleNew(
      msg.sender, _sale_token, _token_rate, _raise_min, _raise_max,
      _softcap, _hardcap, _whitelist, 
      _presale_start, _presale_end ,_refund
    );
    emit CreateEvent(address(newToken));
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}