pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2; // needed to be able to pass string arrays and structs into functions

/// @title Election Factory
/// @author Johannes Mols
/// @dev This contract spawns election contracts that can be used for voting
contract ElectionFactory {
    address public factoryManager;
    address[] public deployedElections;

    /// @dev initializes the contract and sets the contract manager to be the deployer of the contract
    constructor() public {
        factoryManager = msg.sender;
    }

    /// @dev only the factory manager is allowed functions marked with this
    /// @notice functions with this modifier can only be used by the administrator
    modifier restricted() {
        require(msg.sender == factoryManager, "only the factory manager is allowed to use this function");
        _;
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
                    _timeLimit
                )
            )
        );
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
    struct Option {
        string title;
        string description;
        uint voteCount;
    }

    address public electionFactory;
    address public electionManager;
    string public title;
    string public description;
    uint public startTime;
    uint public timeLimit;
    Option[] public options;

    /// @dev initializes the contract with all required parameters and sets the manager of the contract
    constructor(
        address _manager,
        string memory _title,
        string memory _description,
        uint _startTime,
        uint _timeLimit
    ) public {
        electionFactory = msg.sender;
        electionManager = _manager;
        title = _title;
        description = _description;
        startTime = _startTime;
        timeLimit = _timeLimit;
    }

    /// @dev only the factory manager is allowed functions marked with this
    /// @notice functions with this modifier can only be used by the administrator
    modifier manager() {
        require(msg.sender == electionManager, "only the election manager is allowed to use this function");
        _;
    }

    modifier factory() {
        require(msg.sender == electionFactory, "only the election factory is allowed to use this function");
        _;
    }

    modifier beforeElection() {
        require(now < startTime, "only allowed before election");
        _;
    }

    modifier duringElection() {
        require(now > startTime && now < timeLimit, "only allowed during election");
        _;
    }

    modifier afterElection() {
        require(now > timeLimit, "only allowed after election");
        _;
    }

    function addOption(string memory _title, string memory _description) public manager beforeElection {
        options.push(Option({ title: _title, description: _description, voteCount: 0 }));
    }

    function getOptions() public view returns(Option[]) {
        return options;
    }
}