#!/usr/bin/python

from numpy import *
from random import *
import logging 
logging.root.setLevel(logging.INFO)


alpha = 0.7
gamma= 0.6
new = []
top50 = []
next50=[]
NewSongDict={}
SongDict = {}

#Coded only the part where the user manually selects songs and player learns the user
#The states,action pair is defined as (current_song,how_much_heard(%),next_song)
#	Heard : we use only 10%,50% and 80%
#	Table : we store the values of the states in dictionary called Table.
#		We initialise new entries to 0
#Since we are use the concept of immediate step prediction:
#based on how many times we have used the player and the heard(%) of the song we assign reward
#This reward is assigned to two places:
	#1. Reward Matrix: The reward matrix will be used for our "creating sets"
	#2. UpdateQvalues: This is where we update the state  (curr_song,heard(%),next_song)
	#	2.1. If a state is not present in the table we simply add it.
	#	basically we are adding statess that  we are experiencing. 
	#	we update the state like this : table[state] += alpha(reward + gamma*(highestQvalue(next_state))-table[state])
	# 	How to compute the highestQvalue of next_state:
	#		next_state = (next_song,[10,50,80],[all the possible songs])
	#		so, when the user selects a song->
	#			in the loop it computes all the possible states by the next song
	#			if the state doesnt exist in the table  then add the state to table and initialise to 0
	#		pass this (current_state,heard(%),all the next state keys) to the updateQvalue function


#example : (A,10,B) : i heard 10% of A and switched to B. table[(A,10,B)]=0+alpha(-1+0-0)
#	:  (B,80,D) : heard 80% of B and transit to D. table[(B,80,D)]=0+alpha(5+0-0)
#	:  (D,80,A):  heard 80% of D and transit to A. table[(D,80,A)]=0+alpha(5+0-0) : 0 bcoz highestQvalued(A) is 0 not -1

#SIMPLE MODE : player takes its own intelligent decision
#USER MODE : user selects songs and player understands

#Reason why we are considering the HighestQvalue(next_state)
#Say we are in "SIMPLE Mode" and the user doesnt make any selection.
#user listens to A only 10% and wishes to switch. it will check for which song[A,B,C,D,E..] table(A,10%,[A,B,C,D,E...]) gives the max value
# say the guy heard E many times in general . It will obviously have high reward 
# in "USER MODE" if we are at (A,10,E) ... it will select the highestQvalue of E and make some update
# say B is heard not much often as compared to E but user selects B after 10% of A
# in "USER MODE"  we are at (A,10,B) ... it will select the highestQvalue of B and make some update 
# SAY NOW WE ARE in "SIMPLE MODE"
# we wish to hear only 10% of A...so the state is (A,10,action): it will select E coz (A,10,E) gives the max reward


def jump(RewardMatrix): 
        n=size(RewardMatrix)
        n=n+0.0
        cumilative = RewardMatrix.sum()
        Reward = log(cumilative*(n/(n+1)))
        return Reward

def reward_fun(heard):
	if heard==10:
		return -1.0
	if heard==50:
		return 2.0
	else:
		return 5.0


def highestQvalue(table,next_states):
	max_val = []
	for i in next_states:
		max_val.append(table[i])
	logging.info('The MAX value returned {0}'.format(max(max_val)))
	return max(max_val)


def update(table,state,r,next_states,n):
	global alpha,gamma
	expected = r + gamma*highestQvalue(table,next_states)
	change = alpha*(expected - table[state])
	#alpha = alpha/n	Note: alpha should keep decreasing right?
	table[state]+=change
	logging.info('The {0} value:{1}'.format(state,table[state]))

#ADIRA U CAN IGNORE THIS .... This was just copy pasted from the previous code
def create_sets(RewardMatrix):
	global new,top50,next50
        for i in enumerate(RewardMatrix): #adding the song index as well as the score! index is the song's identity 
                new = list(new)
                top50= list(top50)


                if RewardMatrix[i[0]].sum() == 0: #If the song is unheard / New
                        NewSongDict[i[0]]=0 #add the new song and the point=0
                        logging.info('New Song \n')
                else:

                        SongDict[i[0]]=RewardMatrix[i[0]].sum() #update the dict with new scores
                        logging.info('Already Heard {0} and SongDict[curr]={1}\n'.format(i[0],SongDict[i[0]]))

        HighestRewardList= sorted(SongDict.iteritems(), key=lambda x:x[1],reverse= True) #Based on Reward sort the SongDict
        new = sorted(NewSongDict.iteritems()) #basically returning a list of tupules with no repeatition or else have to use a loop to keep adding
        logging.info("Creating Sets\n")

        #Converting to set type
        top50=set(HighestRewardList[:((len(HighestRewardList)/2))])
        next50 = set(HighestRewardList[(len(HighestRewardList)/2):])
        new= set(new)
        logging.info('top50 next50 new--> sets are updated\n')

        for songs in HighestRewardList: #displaying the top songs
                print songs

	

def main():
	print 'SIMPLE MODE'
	print ' THE PROGRAM MAKES THE PREDICTION \n'
	curr = input('enter a song:')
	while True:
		hear = input('how much heard:')
		action = choose(curr,hear)
		curr = action


# This is where the player learns the user
if __name__=='__main__':
	
	R = [[0.0 for j in range(10)]for i in range(10)]
	R = array(R)
	# Create a table which contains state action pair
	# key: song,(how_much_heard,action)
	# value: reward 
	
	table = {}
	songs=[0,1,2,3,4,5,6,7,8,9]
	used = 0
	percentage = [10,50,80]
	print ' USER MODE \n'
	song = input('enter song no (1-10):') #intial state song
	
	while True:
		#stupid indexing error               
		top50=list(top50)
                next50=list(next50)
                new=list(new)

		heard = input('How much have you heard (10%,50%,80%):')
		state_key = []
		for each_song in songs:
			state_key.append((song,heard,each_song)) # appending all the possible state action pairs for that song
		for states in state_key:
			if states not in table:
				table[states]=0 # assigning reward 0 for every new state witnessed 
				logging.info('New Entries added for that heard {0} : {1}'.format(heard,states[-1]))
		
		next_states = [] #list to add all the next song possible states
		selection = input('enter the song you would like to hear next:')
		
		if used>10  and (SongDict.get(song)<top50[0][1]/2 ):
			R = array(R)	
			r = reward_fun(heard)+jump(R)  #reward is based on the basis of the hearing % 
			R[song][selection]+=r 		#even if its a new song reward_fun will punish the ln function if song is hated
		else:
			r = reward_fun(heard)
			R = array(R)
			R[song][selection]+= r

		R = mat(R.copy())
		
		#creating all possible state,actions pair with state as "selection"
		for per in percentage: 
			for each_song in songs:
				next_states.append((selection,per,each_song))
		for states in next_states:
			if states not in table:
				table[states] = 0

		state = (song,heard,selection)
		logging.info('THE CHOSEN STATE : {0}'.format(state))
		used+=1

		update(table,state,r,next_states,used) #This is where we update the chosen state
		song = selection
		create_sets(R) #this was used in our earlier program. Just copy pasted 
		
		choice = raw_input('Exit mode? ')
		if choice=='y':
			break
	
	
	for i in table.iteritems():
		if i[1]!=0:
			print i

