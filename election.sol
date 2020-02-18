pragma solidity ^0.4.21;

contract Election {
    struct Candidate {
        string name; /// Name of the restaurant
        uint vote_Count; ///Number of votes the restaurant got
    }
    
    struct Voter {
        bool authorized; /// to check if the person is authorized to vote
        bool voted;  /// To check if the person voted for someone
        uint vote ; /// To check who the person voted for
    }
    

    //State Variables
    address public owner ;
    string public electionName ; // What the election is about
    string winner_name ;
    uint winner_votes  = 0; 
    bool flag = false ;// To check if the candidate already exists.
    bool flag_2 = false ; // To check if the election is over.
    uint public auctionEnd;
    uint public quorum ;
    
    mapping(address => Voter) public voters;
    Candidate[] public candidates; //Array of candidates
    uint public totalVotes; // Total number of votes

    
    modifier ownerOnly(){
        require (msg.sender == owner);
        _; 
    }
    
    event CurrentElectionResult(string name, uint vote_Count);
    event ElectionWinnerList(string name, uint vote_Count);
    event Error (string name);
    event ElectionEnded (string name);
    event Listing_candidates (string name);
    
    
    
    function Election(string _name, string candidate1, string candidate2, uint durationMinutes, address[] _person, uint q) public {
        //Must pass an array of the addresses of people.
        
        //Constructor for the contract
        //Initialize with two candidates
        owner = msg.sender;
        quorum = q;
        electionName = _name;
        authorize(owner); // owner is automatically allowed to vote
        auctionEnd = now + (durationMinutes  * 1 minutes);
        
        if(keccak256(candidate1) == keccak256(candidate2)){
            //To check if the two candidates aren't the same
            candidates.push(Candidate(candidate1, 0));
            emit Error("Only one candidate was added as the same candidate was passed twice");
        }
        else{
            candidates.push(Candidate(candidate1, 0));
            candidates.push(Candidate(candidate2, 0));
            
        for(uint i ; i<_person.length; i++){
                voters[_person[i]].authorized = true;
            }
        }
       
    }
    
    function addCandidate(string _name) ownerOnly public {
        //To add a new candidates
        flag = false;
    
        for (uint i; i<candidates.length;i++){
            if(keccak256(candidates[i].name) == keccak256(_name)){
                emit Error("Candidate Already Exists.");
                flag =true ;
                
            }
            
        }
        if ((flag) == false){
            candidates.push(Candidate(_name, 0));
        }
    }
    
    function listoutcandidates () public{
       for (uint i =0 ; i <candidates.length; i++){
       emit ElectionWinnerList(candidates[i].name,candidates[i].vote_Count);
        }
    }
    
    function getNumCandidate() public  view returns(uint){
        // To get the number of candidates
        return candidates.length;
    }
    
    function authorize (address _person) ownerOnly public {
        // To authorize a person to vote
        voters[_person].authorized = true;
    }

    function vote(uint _voteIndex) public{
        if(now >= auctionEnd){
            flag_2 = true; 
            emit ElectionEnded("Time limit  has been reached. Election has ended."); 
            getResult();
        }
        else if (totalVotes>=quorum) {
            flag_2 = true; 
            emit ElectionEnded("Quorum has been reached. Election has ended."); 
            getResult();
        }
        
        else{
            // Function to vote. Checks authorization and then allows to vote.
            require(!voters[msg.sender].voted); // Check if the person hasn't voted already.
            require(voters[msg.sender].authorized); // Check if the person is authorized.
            
            voters[msg.sender].vote = _voteIndex;
            voters[msg.sender].voted = true;
            
            candidates[_voteIndex].vote_Count += 1;
            totalVotes += 1;
        }
            
    }   
    
    function getResult() public{
        uint i=0;
        if(flag_2 ==false){
        for (i=0; i <candidates.length; i++){
            emit CurrentElectionResult(candidates[i].name,candidates[i].vote_Count);
            if (winner_votes < candidates[i].vote_Count){
                winner_votes = candidates[i].vote_Count;
                 }
            }
        }
        else{
            for (i==0 ; i <candidates.length; i++){
            if (winner_votes < candidates[i].vote_Count){
                winner_votes = candidates[i].vote_Count;
             }
            for (i =0 ; i <candidates.length; i++){
                   if (winner_votes == candidates[i].vote_Count){
                       emit ElectionWinnerList(candidates[i].name,candidates[i].vote_Count);
                   }
            }
         }
        }
    }
    
    function end() ownerOnly public{
        flag_2 = true;
        getResult();
        selfdestruct(owner);
        
    }
    
}




/* Smart contract can be extended to display the dishes available at the restaurant
An array can keep track of the name of the dishes that are there in the restaurant.
You can also add a voting policy for the dishes using a similar logic as shown above.


Smart contract could also be extended to include more information about the restaurant eg. Location, Timings etc. A struct could be used to 
keep track of all the variables of the restaurant

Contract can be extended to allow a functionality that shows the voter that his vote has been accepted.

A trigger could also be set to show the winner of the voting poll, by sending out an email.

Developing a real time front end for the contract will also allow users to keep track of the votes and options.

*/
