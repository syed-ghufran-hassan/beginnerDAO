// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../src/BeginnerDAO.sol";

contract BeginnerDAOTest is Test {
    BeginnerDAO public dao;
    address public owner;
    address public voter1;
    address public voter2;

    function setUp() public {
        // Setup initial environment
        owner = address(0xABCD);  // Mock owner address
        voter1 = address(0x1234); // Mock voter 1
        voter2 = address(0x5678); // Mock voter 2

        // Label addresses for clarity in logs
        vm.label(owner, "Owner");
        vm.label(voter1, "Voter 1");
        vm.label(voter2, "Voter 2");

        // Deploy the DAO contract as the owner
        vm.prank(owner);
        dao = new BeginnerDAO();
    }

    function testCreateProposal() public {
        // Ensure only the owner can create a proposal
        vm.startPrank(owner);
        dao.createProposal("Proposal 1", 1 days);
        vm.stopPrank();

        // Verify proposal data
        (
            string memory description,
            uint256 votesFor,
            uint256 votesAgainst,
            uint256 deadline,
            bool executed
        ) = dao.proposals(1);

        assertEq(description, "Proposal 1");
        assertEq(votesFor, 0);
        assertEq(votesAgainst, 0);
        assertGt(deadline, block.timestamp);
        assertEq(executed, false);
    }

    function testVoting() public {
        // Owner creates a proposal
        vm.prank(owner);
        dao.createProposal("Proposal 1", 1 days);

        // Voter 1 votes for the proposal
        vm.prank(voter1);
        dao.vote(1, true);

        // Voter 2 votes against the proposal
        vm.prank(voter2);
        dao.vote(1, false);

        // Verify votes
        (
            ,
            uint256 votesFor,
            uint256 votesAgainst,
            ,
        ) = dao.proposals(1);

        assertEq(votesFor, 1);
        assertEq(votesAgainst, 1);
    }

    function testVotingFailsAfterDeadline() public {
        // Owner creates a proposal with a short duration
        vm.prank(owner);
        dao.createProposal("Proposal 1", 1 seconds);

        // Advance time past the deadline
        vm.warp(block.timestamp + 2);

        // Attempt to vote after the deadline
        vm.prank(voter1);
        vm.expectRevert("Voting has ended");
        dao.vote(1, true);
    }

    function testVoteOnlyOnce() public {
        // Owner creates a proposal
        vm.prank(owner);
        dao.createProposal("Proposal 1", 1 days);

        // Voter 1 votes
        vm.prank(voter1);
        dao.vote(1, true);

        // Voter 1 tries to vote again
        vm.prank(voter1);
        vm.expectRevert("Already voted");
        dao.vote(1, true);
    }

    function testExecuteProposal() public {
        // Owner creates a proposal
        vm.prank(owner);
        dao.createProposal("Proposal 1", 1 days);

        // Advance time to end of voting
        vm.warp(block.timestamp + 1 days);

        // Execute the proposal
        vm.prank(owner);
        dao.executeProposal(1);

        // Verify execution status
        (
            ,
            ,
            ,
            ,
            bool executed
        ) = dao.proposals(1);

        assertEq(executed, true);
    }

    function testExecuteBeforeDeadlineFails() public {
        // Owner creates a proposal
        vm.prank(owner);
        dao.createProposal("Proposal 1", 1 days);

        // Attempt to execute before the deadline
        vm.prank(owner);
        vm.expectRevert("Voting not ended");
        dao.executeProposal(1);
    }

    function testOnlyOwnerCanExecute() public {
        // Owner creates a proposal
        vm.prank(owner);
        dao.createProposal("Proposal 1", 1 days);

        // Advance time to end of voting
        vm.warp(block.timestamp + 1 days);

        // Attempt to execute the proposal as a non-owner
        vm.prank(voter1);
        vm.expectRevert("Not authorized");
        dao.executeProposal(1);
    }
}
