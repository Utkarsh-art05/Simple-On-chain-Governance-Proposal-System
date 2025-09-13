module MyModule::Governance {
 
    use aptos_framework::signer;
    use aptos_framework::timestamp;
 
    /// Struct representing a governance proposal.
    struct Proposal has store, key {
        title: vector<u8>,        // Title of the proposal
        description: vector<u8>,  // Description of the proposal
        yes_votes: u64,          // Number of yes votes
        no_votes: u64,           // Number of no votes
        end_time: u64,           // Voting end timestamp
        is_executed: bool        // Whether proposal has been executed
    }
 
    /// Struct to track if an address has already voted.
    struct VoteRecord has store, key {
        has_voted: bool
    }
 
    /// Function to create a new governance proposal.
    public fun create_proposal(
        proposer: &signer, 
        title: vector<u8>, 
        description: vector<u8>, 
        voting_duration: u64
    ) {
        let current_time = timestamp::now_seconds();
        let proposal = Proposal {
            title,
            description,
            yes_votes: 0,
            no_votes: 0,
            end_time: current_time + voting_duration,
            is_executed: false
        };
        move_to(proposer, proposal);
    }
 
    /// Function for users to vote on a proposal.
    public fun vote_on_proposal(
        voter: &signer, 
        proposal_owner: address, 
        vote_yes: bool
    ) acquires Proposal {
        let voter_addr = signer::address_of(voter);
        let proposal = borrow_global_mut<Proposal>(proposal_owner);
        
        // Check if voting period is still active
        let current_time = timestamp::now_seconds();
        assert!(current_time < proposal.end_time, 1);
        
        // Check if user has already voted and prevent double voting
        if (!exists<VoteRecord>(voter_addr)) {
            let vote_record = VoteRecord { has_voted: true };
            move_to(voter, vote_record);
            
            // Record the vote
            if (vote_yes) {
                proposal.yes_votes = proposal.yes_votes + 1;
            } else {
                proposal.no_votes = proposal.no_votes + 1;
            };
        };
    }
}