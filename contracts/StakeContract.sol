// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./StakeStruct.sol";
import "./StakeEnum.sol";

contract StakeContract {
  address public owner;
  uint256 private _stakeNumber;
  uint256 private _counter;

  mapping(uint256 => StakeInfo) private _stakes;
  mapping(uint256 => StakeHistory[]) private _stakeId_histories;
  mapping(uint256 => address[]) private _map_StakeId_Addresses;
  mapping(address => uint256[]) private _map_Address_StakeIds;
  mapping(address => mapping(uint256 => uint256))
    private _map_last_deposit_on_stake; // address => StakeId => unix time

  constructor() {
    owner = msg.sender;
  }

  function generateId() private returns (uint256) {
    _counter++;
    uint256 id = uint256(
      keccak256(abi.encodePacked(block.timestamp, msg.sender, _counter))
    );
    return id;
  }

  function createStake(
    address[] memory addresses,
    StakeFrequency frequency,
    uint256 frequencyAmount,
    uint256 end
  ) external payable returns (uint256) {
    // id for stake
    uint256 id = generateId();

    // map address and stakes
    _map_StakeId_Addresses[id] = addresses;

    for (uint256 index = 0; index < addresses.length; index++) {
      _map_Address_StakeIds[addresses[index]].push(id);
    }

    _stakeNumber++;

    StakeInfo memory info;

    info.id = id;
    info.frequency = frequency;
    info.frequencyAmount = frequencyAmount;
    info.start = block.timestamp;
    info.end = end;

    _stakes[id] = info;

    return id;
  }

  function getStakeInfo(uint256 id) external view returns (StakeInfo memory) {
    return _stakes[id];
  }

  function getAddressesByStakeId(
    uint256 id
  ) external view returns (address[] memory) {
    return _map_StakeId_Addresses[id];
  }

  function getStakesByAddress(
    address adr
  ) external view returns (StakeInfo[] memory) {
    uint256[] memory ids = _map_Address_StakeIds[adr];
    StakeInfo[] memory infos;

    for (uint256 index = 0; index < ids.length; index++) {
      infos[index] = _stakes[ids[index]];
    }

    return infos;
  }

  function getHistoryById(uint256 id) public view returns(StakeHistory[] memory){
    return _stakeId_histories[id];
  }

  function depositStake(
    uint256 stakeId
  ) public payable returns (StakeHistory memory) {
    uint256 val = msg.value;
    uint256 requireAmount = _stakes[stakeId].frequencyAmount;

    require(val == requireAmount, "Value must be equal to requireAmount");

    StakeHistory memory history;

    history.date = block.timestamp;
    history.amount = val;
    _stakeId_histories[stakeId].push(history);

    return history;
  }
}
