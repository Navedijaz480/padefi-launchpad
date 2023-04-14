// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract PadeFiVesting {
    
    address public owner;
    address public token;
    uint256 public totalTokens;
    uint256 public startTime;
    uint256 public firstRelease;// enter percentage 
    uint256 public vestingPeriod; //enter in minute 
    uint256 public ReleaseEveryCycle; //release amount on every cycle //enter percentage 
    uint256 public releasedTokens;
    
    constructor(address _owner, address  _token, uint256 _totalTokens,  uint256 _firstRelease, uint256 _vestingPeriod, uint256 _ReleaseEveryCycle) {
        owner = _owner;
        token = _token;
        totalTokens = _totalTokens;
       
        startTime = block.timestamp;
        firstRelease = _firstRelease;
        vestingPeriod = _vestingPeriod*60;
        ReleaseEveryCycle = _ReleaseEveryCycle;
    }
    modifier onlyOwner {
        require(owner==msg.sender,"only owner can call");
        _;
    }
    
    function releaseTokens() public onlyOwner {
        uint256 currentTime = block.timestamp;
        require(currentTime >= startTime + vestingPeriod, "Tokens are locked until the vestingperiod is over.");
        uint256 releasableTokens = getReleasableTokens(currentTime);
        require(releasableTokens > 0, "No tokens are currently available for release.");
        require(releasedTokens + releasableTokens <= totalTokens, "Insufficient tokens for release.");
        releasedTokens += releasableTokens;
        startTime =block.timestamp;
        require(IBEP20(token).transfer(owner, releasableTokens), "Token transfer failed.");
    }
    
    function getReleasableTokens(uint256 currentTime) public view returns (uint256 releaseToken) {
         uint256 unreleasedTokens = (totalTokens-(totalTokens)/firstRelease);
         uint256 vestingtotalPeriod=1+(unreleasedTokens/ReleaseEveryCycle);
         uint256 vestingTotalDuration=vestingPeriod*vestingtotalPeriod;
        if (currentTime < startTime + vestingPeriod) {
            return 0;
        }
        uint256 totalTime = startTime + vestingTotalDuration;
        if (currentTime >= totalTime) {
           return totalTokens - releasedTokens;
        }
         if (currentTime > startTime + vestingPeriod) {
             if(releasedTokens ==0){
            return (firstRelease*totalTokens)/100;
             }
             else {
                 if((releasedTokens+(ReleaseEveryCycle*totalTokens)/100)>=totalTokens){
                  if( (totalTokens-releasedTokens) >0){
                      return totalTokens-releasedTokens;
                  }
                  else
                  return (ReleaseEveryCycle*totalTokens)/100;

                 }
                 else
                 return (ReleaseEveryCycle*totalTokens)/100;
             }
        }
        if ( currentTime >=startTime + vestingPeriod){
            uint256 cyclegone= (currentTime/(startTime+vestingPeriod));
            if (cyclegone>=1){
            return cyclegone*(ReleaseEveryCycle*totalTokens)/100;
            }
        }
  
    }
}