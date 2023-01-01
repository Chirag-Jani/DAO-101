// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDAO_Whitelist {
    receive() external payable;

    function checkAvailableFund() external;

    function withdrawFund() external;

    function addSpots(uint8 newSpots) external;

    function makeItPaid(uint8 amount) external;

    function whitelistMe() external;

    function isWhitelisted(address user) external view returns (bool);
}
