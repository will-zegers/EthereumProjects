pragma solidity ^0.4.14;

contract Voting {
  struct Voter {
    bool hasVoted;
    uint proposalIndex;
    bool hasRightToVote;
  }

  struct Proposal {
    bytes32 name;
    uint voteCount;
  }

  address public chairperson;
  uint public votingStartTime;
  uint public votingDuration;
  uint public numProposals;
  mapping (address => Voter) public voters;
  mapping (uint => Proposal) public proposals;

  function Voting(bytes32[] proposalNames, uint _votingTime) {
    chairperson = msg.sender;
    voters[chairperson].hasRightToVote = true;
    votingStartTime = now;
    votingDuration = _votingTime;
    numProposals = proposalNames.length;

    for (uint i = 0; i < numProposals; ++i) {
      Proposal storage p = proposals[i];
      p.name = proposalNames[i];
      p.voteCount = 0;
    }
  }

  function giveRightToVote(address voter) {
    require(msg.sender == chairperson && !voters[voter].hasVoted);
    voters[voter].hasRightToVote = true;
  }

  function vote(uint proposal) {
    require(now < votingStartTime + votingDuration);

    Voter storage voter = voters[msg.sender];

    require(!voter.hasVoted);
    voter.hasVoted = true;
    voter.proposalIndex = proposal;

    proposals[proposal].voteCount++;
  }

  function getWinningProposal() constant
    returns (uint winningProposal, bytes32 proposalName) {

    require(now > votingStartTime + votingDuration);

    uint winningVoteCount = 0;
    for (uint p = 0; p < numProposals; ++p) {
      if (proposals[p].voteCount > winningVoteCount) {
        winningVoteCount = proposals[p].voteCount;
        winningProposal = p;
        proposalName = proposals[p].name;
      }
    }
  }
}