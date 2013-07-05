Coded only the part where the user manually selects songs and player learns the user.
The states,action pair is defined as (current_song,how_much_heard(%),next_song).
       Heard : we use only 10%,50% and 80%.
       Table : we store the values of the states in dictionary called Table.
               We initialise new entries to 0.
Since we are use the concept of immediate step prediction:
based on how many times we have used the player and the heard(%) of the song we assign reward.
This reward is assigned to two places:
        1. Reward Matrix: The reward matrix will be used for our "creating sets"
        2. UpdateQvalues: This is where we update the state  (curr_song,heard(%),next_song)
               2.1. If a state is not present in the table we simply add it.
               basically we are adding statess that  we are experiencing. 
               we update the state like this : table[state] += alpha(reward + gamma*(highestQvalue(next_state))-table[state])
               How to compute the highestQvalue of next_state:
                      next_state = (next_song,[10,50,80],[all the possible songs])
                       so, when the user selects a song->
                               in the loop it computes all the possible states by the next song
                               if the state doesnt exist in the table  then add the state to table and initialise to 0
                       pass this (current_state,heard(%),all the next state keys) to the updateQvalue function


example : (A,10,B) : i heard 10% of A and switched to B. table[(A,10,B)]=0+alpha(-1+0-0)
       :  (B,80,D) : heard 80% of B and transit to D. table[(B,80,D)]=0+alpha(5+0-0)
       :  (D,80,A):  heard 80% of D and transit to A. table[(D,80,A)]=0+alpha(5+0-0) : 0 bcoz highestQvalued(A) is 0 not -1

SIMPLE MODE : player takes its own intelligent decision
USER MODE : user selects songs and player understands

Reason why we are considering the HighestQvalue (nextstate)
Say we are in "SIMPLE Mode" and the user doesnt make any selection.
user listens to A only 10% and wishes to switch. it will check for which song[A,B,C,D,E..] table(A,10%,[A,B,C,D,E...]) gives the max value
 say the guy heard E many times in general . It will obviously have high reward 
 in "USER MODE" if we are at (A,10,E) ... it will select the highestQvalue of E and make some update
 say B is heard not much often as compared to E but user selects B after 10% of A
 in "USER MODE"  we are at (A,10,B) ... it will select the highestQvalue of B and make some update 
 SAY NOW WE ARE in "SIMPLE MODE"
 we wish to hear only 10% of A...so the state is (A,10,action): it will select E coz (A,10,E) gives the max reward

