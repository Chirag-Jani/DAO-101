// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Whitelist {
    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    address public owner;
    uint8 public maxWhitelist;
    uint8 public whitelistFees;
    uint8 public currentWhitelisted;
    bool public isPaid;

    mapping(address => bool) alreadyWhitelisted;

    constructor(uint8 _maxWhitelist) {
        owner = msg.sender;
        maxWhitelist = _maxWhitelist;
    }

    function withdrawFund() public payable onlyOwner {
        // transfer funds
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Error withdrawing funds");
    }

    function addSpots(uint8 newSpots) public onlyOwner {
        require(currentWhitelisted == maxWhitelist, "Limit must be reached");

        maxWhitelist += newSpots;
    }

    function makeItPaid(uint8 amount) public onlyOwner {
        isPaid = true;
        whitelistFees = amount;
    }

    function checkAvailableFund() public view returns (uint256) {
        // return funds
        return address(this).balance;
    }

    function whitelistMe() public payable {
        // not already
        require(
            alreadyWhitelisted[msg.sender] == false,
            "You are already whitelisted"
        );

        // space available
        require(currentWhitelisted < maxWhitelist, "Maximum limit reached");

        // only executed if paid
        if (isPaid) {
            // check fund
            require(msg.value >= whitelistFees, "Not enough funds");

            // transfer fund
            (bool success, ) = address(this).call{value: msg.value}("");
            require(success, "Address: unable to send value, try again later");
        }

        // whitelist user
        alreadyWhitelisted[msg.sender] = true;

        // decrease space by increasing current whitelisted users
        currentWhitelisted += 1;
    }

    // to check if any user is whitelisted
    function isWhitelisted(address user) public view returns (bool) {
        return alreadyWhitelisted[user];
    }
}
