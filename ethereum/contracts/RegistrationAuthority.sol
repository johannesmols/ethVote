pragma solidity ^0.4.26;

contract RegistrationAuthority {
    address public manager;

    mapping(address => bool) public voters;
    uint public voterCount;

    /// @dev initializes the contract and sets the contract manager to be the deployer of the contract
    constructor() public {
        manager = msg.sender;
    }

    /// @dev only the factory manager is allowed functions marked with this
    /// @notice functions with this modifier can only be used by the administrator
    modifier restricted() {
        require(msg.sender == manager, "only the contract manager is allowed to use this function");
        _;
    }

    /// @dev use this to register a voter
    function registerVoter(address _voter) public restricted {
        voters[_voter] = true;
        voterCount++;
    }

    /// @dev use this to unregister a voter
    function unregisterVoter(address _voter) public restricted {
        voters[_voter] = false;
        voterCount--;
    }
}