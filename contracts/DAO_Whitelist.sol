// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract DAO_Whitelist {
    // to receive the funds
    receive() external payable {}

    // modifier to check if the caller is the owner or not
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    // the deployer is the owner
    address public owner;

    // maximum spots available
    uint8 public maxWhitelist;

    // currently added users
    uint8 public currentWhitelisted;

    // fees to get involved
    uint8 public whitelistFees;

    // make the process paid
    bool public isPaid;

    // to check if user is already whitelisted or not
    mapping(address => bool) alreadyWhitelisted;

    // send maximum limit while deploying
    constructor(uint8 _maxWhitelist) {
        owner = msg.sender;
        maxWhitelist = _maxWhitelist;
    }

    // withdraw the funds - only owner can
    function withdrawFund() public payable onlyOwner {
        // transfer funds
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Error withdrawing funds");
    }

    // add more spots to get whitelisted
    function addSpots(uint8 newSpots) public onlyOwner {
        require(currentWhitelisted == maxWhitelist, "Limit must be reached");

        maxWhitelist += newSpots;
    }

    // make the whitelisting paid
    function makeItPaid(uint8 amount) public onlyOwner {
        isPaid = true;
        whitelistFees = amount;
    }

    // get received funds (anyone can see)
    function checkAvailableFund() public view returns (uint256) {
        // return funds
        return address(this).balance;
    }

    // whitelsit the user
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

        // TODO: Mint an NFT to the sender
    }

    // to check if any user is whitelisted
    function isWhitelisted(address user) public view returns (bool) {
        return alreadyWhitelisted[user];
    }
}
