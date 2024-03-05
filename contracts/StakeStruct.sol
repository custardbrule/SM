// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./StakeEnum.sol";

struct StakeHistory {
  uint256 date;
  uint256 amount;
}

struct StakeInfo {
  uint256 id;
  uint256 start;
  uint256 end;
  StakeFrequency frequency;
  uint256 frequencyAmount; // in gwei
}
