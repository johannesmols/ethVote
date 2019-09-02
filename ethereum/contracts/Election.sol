pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2; // needed to be able to pass string arrays and structs into functions

contract ElectionFactory {
    address public factoryManager;
    address[] public deployedElections;

    // Due to limitations of not being able to pass struct arrays or mappings into functions
    string[] private tmpOptionsTitle;
    string[] private tmpOptionsDescription;

    constructor() public {
        factoryManager = msg.sender;
    }

    modifier restricted() {
        require(msg.sender == factoryManager, "only the factory manager is allowed to use this function");
        _;
    }

    function addOption(string memory _title, string memory _description) public restricted {
        require(tmpOptionsTitle.length == tmpOptionsDescription.length, "options arrays are not of equal sizes");
        tmpOptionsTitle.push(_title);
        tmpOptionsDescription.push(_description);
    }

    function createElection(string memory _title, string memory _description, uint _timeLimit) public restricted {
        deployedElections.push(
            address(
                new Election(
                    factoryManager,
                    _title,
                    _description,
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

    function getDeployedElections() public view returns(address[] memory) {
        return deployedElections;
    }
}

contract Election {
    address public electionManager;
    string public title;
    string public description;
    uint public timeLimit;
    string[] public optionsTitle;
    string[] public optionsDescription;

    constructor(
        address _manager,
        string memory _title,
        string memory _description,
        uint _timeLimit,
        string[] memory _optionsTitle,
        string[] memory _optionsDescription
    ) public {
        electionManager = _manager;
        title = _title;
        description = _description;
        timeLimit = _timeLimit;
        optionsTitle = _optionsTitle;
        optionsDescription = _optionsDescription;
    }
}