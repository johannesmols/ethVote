pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2; // needed to be able to pass string arrays and structs into functions

/// @title Election Factory
/// @author Johannes Mols
/// @dev This contract spawns election contracts that can be used for voting
contract ElectionFactory {
    address public factoryManager;
    address[] public deployedElections;

    // Due to limitations of not being able to pass struct arrays or mappings into functions
    string[] private tmpOptionsTitle;
    string[] private tmpOptionsDescription;

    /// @dev initializes the contract and sets the contract manager to be the deployer of the contract
    constructor() public {
        factoryManager = msg.sender;
    }

    /// @dev only the factory manager is allowed functions marked with this
    /// @notice functions with this modifier can only be used the administrator
    modifier restricted() {
        require(msg.sender == factoryManager, "only the factory manager is allowed to use this function");
        _;
    }

    /// @dev use this to add voting options to the temporary list of options that will be used when creating an Election contract
    /// @param _title specifies the title of the option (e.g. candidate name)
    /// @param _description specifies the description of the option (e.g. party affiliation)
    function addOption(string memory _title, string memory _description) public restricted {
        require(tmpOptionsTitle.length == tmpOptionsDescription.length, "options arrays are not of equal sizes");
        tmpOptionsTitle.push(_title);
        tmpOptionsDescription.push(_description);
    }

    /// @dev use this to deploy new Election contracts and reset the temporary options lists afterwards
    /// @param _title specifies the name of the election (e.g. national elections)
    /// @param _description specifies the description of the election
    /// @param _startTime specifies the beginning of the election (since Unix Epoch in seconds)
    /// @param _timeLimit specifies a time limit until when the election is open (since Unix Epoch in seconds)
    function createElection(string memory _title, string memory _description, uint _startTime, uint _timeLimit) public restricted {
        deployedElections.push(
            address(
                new Election(
                    factoryManager,
                    _title,
                    _description,
                    _startTime,
                    _timeLimit,
                    tmpOptionsTitle,
                    tmpOptionsDescription
                )
            )
        );

        // Reset temporary variables for next contract deployment
        delete tmpOptionsTitle;
        delete tmpOptionsDescription;
    }

    /// @dev use this to return a list of addresses of all deployed Election contracts
    /// @return a list of addresses of all deployed Election contracts
    function getDeployedElections() public view returns(address[] memory) {
        return deployedElections;
    }
}

/// @title Election
/// @author Johannes Mols
/// @dev This is the actual election contract where users can vote
contract Election {
    address public electionManager;
    string public title;
    string public description;
    uint public startTime;
    uint public timeLimit;
    string[] public optionsTitle;
    string[] public optionsDescription;

    /// @dev initializes the contract with all required parameters and sets the manager of the contract
    constructor(
        address _manager,
        string memory _title,
        string memory _description,
        uint _startTime,
        uint _timeLimit,
        string[] memory _optionsTitle,
        string[] memory _optionsDescription
    ) public {
        electionManager = _manager;
        title = _title;
        description = _description;
        startTime = _startTime;
        timeLimit = _timeLimit;
        optionsTitle = _optionsTitle;
        optionsDescription = _optionsDescription;
    }
}