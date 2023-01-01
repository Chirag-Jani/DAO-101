// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IDAO_Post {
    function addCategory(string memory _catagory) external;

    function getAvailableCatagories() external view returns (bytes32[] memory);

    function getCatagoryName(bytes32 _catagoryId)
        external
        view
        returns (string memory);

    function createPost(string memory contentString, bytes32 catagoryId)
        external;

    function checkCoolDownTime() external view returns (uint256);

    // ! Not able to return struct here
    // function getAllPosts() external view returns (Post[] memory);

    function getOnePostId(address _creator, bytes32 _catagoryId)
        external
        view
        returns (bytes32);

    // ! Not able to return struct here
    // function getSinglePost(bytes32 _postId) external view returns (Post memory);

    function upVotePost(bytes32 _postId) external;

    function downVotePost(bytes32 _postId) external;

    function tipCreator(bytes32 _postId) external payable;

    function getOriginalContent(bytes32 _contentId)
        external
        view
        returns (string memory);
}
