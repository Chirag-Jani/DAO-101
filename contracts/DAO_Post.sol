// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IDAO_Whitelist.sol";

contract PostContract {
    struct Post {
        address payable creator;
        bytes32 catagoryId;
        bytes32 contentId;
        uint8 upVotes;
        uint8 downVotes;
        uint256 totalTips;
    }

    // get the whitelist contract address (pass while deploying)
    address payable whitelistContractAddress;

    constructor(address _whitelistContractAddress) {
        // setting whitelist contract address
        whitelistContractAddress = payable(_whitelistContractAddress);
    }

    // modifier to check if user is whitelisted or not
    modifier isWhitelisted() {
        require(
            IDAO(whitelistContractAddress).isWhitelisted(msg.sender) == true,
            "You are not whitelisted"
        );
        _;
    }

    // add & get post ids of all the posts
    Post[] posts;

    // add & get post via ids
    mapping(bytes32 => Post) getPost;

    // (id will get you the original content)
    mapping(bytes32 => string) getContent;

    // claim contentids - no one can add content with the same contentid
    mapping(bytes32 => bool) contentClaimed;

    // get the creator of content
    mapping(bytes32 => address) contentClaimedBy;

    // get catagory from catagory id
    mapping(bytes32 => string) getCatagory;

    // creator => contentId => post id
    mapping(address => mapping(bytes32 => bytes32)) getPostId;

    bytes32[] catagoryArray;

    // user has voted on the post or not
    mapping(address => mapping(bytes32 => bool)) voted;

    mapping(address => uint256) coolDownTime;

    // add new catagory
    function addCategory(string memory _catagory) public isWhitelisted {
        bytes32 _catagoryId = keccak256(abi.encode(_catagory));
        getCatagory[_catagoryId] = _catagory;
        catagoryArray.push(_catagoryId);
    }

    // get list of catagories available - bytes[]
    function getAvailableCatagories() public view returns (bytes32[] memory) {
        return catagoryArray;
    }

    // get name of the catagory - get id from getAvailableCatagories()
    function getCatagoryName(bytes32 _catagoryId)
        public
        view
        returns (string memory)
    {
        return getCatagory[_catagoryId];
    }

    // add post
    function createPost(string memory contentString, bytes32 catagoryId)
        public
        isWhitelisted
    {
        address _creator = msg.sender;
        bytes32 _contentId = keccak256(abi.encode(contentString));

        bytes32 _postId = keccak256(abi.encodePacked(_contentId, _creator));

        // check cooldown time
        require(
            coolDownTime[msg.sender] < block.timestamp,
            "you can't add post yet, wait for some time"
        );

        // content must not be claimed
        require(contentClaimed[_contentId] == false, "Content already claimed");

        // claim content
        contentClaimed[_contentId] = true;
        contentClaimedBy[_contentId] = msg.sender;

        // add to post (single & all)
        getPost[_postId] = Post(
            payable(msg.sender),
            catagoryId,
            _contentId,
            0,
            0,
            0
        );
        posts.push(getPost[_postId]);

        // to later get id
        getPostId[msg.sender][_contentId] = _postId;

        // cooldown time
        coolDownTime[msg.sender] = block.timestamp + 5 minutes;

        // to later get original content
        getContent[_contentId] = contentString;
    }

    // check my cooldown time (can only see yours)
    function checkCoolDownTime() public view isWhitelisted returns (uint256) {
        return coolDownTime[msg.sender];
    }

    // get all the posts (array of Post structure)
    function getAllPosts() public view isWhitelisted returns (Post[] memory) {
        return posts;
    }

    // get post's id (get creator's address and catagory id from getAllPosts())
    function getOnePostId(address _creator, bytes32 _catagoryId)
        public
        view
        isWhitelisted
        returns (bytes32)
    {
        return getPostId[_creator][_catagoryId];
    }

    // get single post from the id
    function getSinglePost(bytes32 _postId) public view returns (Post memory) {
        return getPost[_postId];
    }

    // upvote the post
    function upVotePost(bytes32 _postId) public isWhitelisted {
        require(voted[msg.sender][_postId] == false, "User has already voted");
        require(
            getPost[_postId].creator != msg.sender,
            "You can not vote on your own post"
        );
        getPost[_postId].upVotes += 1;
        voted[msg.sender][_postId] = true;
    }

    // downvote the post
    function downVotePost(bytes32 _postId) public isWhitelisted {
        require(voted[msg.sender][_postId] == false, "User has already voted");
        require(
            getPost[_postId].creator != msg.sender,
            "You can not vote on your own post"
        );
        getPost[_postId].downVotes += 1;
        voted[msg.sender][_postId] = true;
    }

    // tip the creator (just pass the post id)
    function tipCreator(bytes32 _postId) public payable isWhitelisted {
        (bool success, ) = getPost[_postId].creator.call{value: msg.value}("");
        require(
            success == true,
            "Could not send the transaction, please try again"
        );
        getPost[_postId].totalTips += msg.value;
    }

    // to read content (in string form as we are encrypting and hashing while storing in struct)
    function getOriginalContent(bytes32 _contentId)
        public
        view
        returns (string memory)
    {
        return getContent[_contentId];
    }
}
