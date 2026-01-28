// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LongevityDAO
/// @notice Governance contract for biotech-backed tokenomics
contract LongevityDAO {
    struct Proposal {
        uint id;
        string title;
        uint longevityWeight;
        uint voteCount;
        bool executed;
    }

    mapping(uint => Proposal) public proposals;
    mapping(address => uint) public healthScore;
    uint public proposalCount;

    event ProposalCreated(uint id, string title, uint longevityWeight);
    event Voted(address voter, uint proposalId, uint weight);
    event Executed(uint proposalId);

    /// @notice Create a proposal with longevity-weighted voting
    function createProposal(string memory _title, uint _longevityWeight) public {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _title, _longevityWeight, 0, false);
        emit ProposalCreated(proposalCount, _title, _longevityWeight);
    }

    /// @notice Vote on a proposal using your healthScore as weight
    function vote(uint _proposalId) public {
        require(healthScore[msg.sender] > 0, "No health score");
        proposals[_proposalId].voteCount += healthScore[msg.sender];
        emit Voted(msg.sender, _proposalId, healthScore[msg.sender]);
    }

    /// @notice Execute proposal if voteCount exceeds threshold
    function execute(uint _proposalId) public {
        Proposal storage p = proposals[_proposalId];
        require(!p.executed, "Already executed");
        require(p.voteCount >= p.longevityWeight, "Insufficient votes");
        p.executed = true;
        emit Executed(_proposalId);
    }

    /// @notice Set health score (off-chain AI model input)
    function setHealthScore(address _user, uint _score) public {
        healthScore[_user] = _score;
    }
}