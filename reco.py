#!/usr/bin/python


###########################################  S.I.M.P.L.E  ALGO ############################################
from numpy import *
import operator

SongDict = {}
heard = 1
unheard = 0 #Newness 


def jump(RewardMatrix):
	n=size(RewardMatrix)
	cumilative = RewardMatrix.sum()
	Reward = log(cumilative*(n/(n+1)))
	return Reward 


def populate_reward(RewardMatrix):

	for i in enumerate(RewardMatrix):
		if RewardMatrix[i[0]].sum() == 0: #if the song is new 
			SongDict[i[0]] = [0,unheard]
		else:
			SongDict[i[0]] = [RewardMatrix[i[0]].sum(), heard] #if the song is heard 

	print '\n\n'
	
	HighestRewardList= sorted(SongDict.iteritems(),key=lambda x: x[1],reverse = True)
	for x in HighestRewardList:
			print x

#def check_heard_reward(RewardMatrix,Curr_pos,selected):

#	if (SongDict[Curr_pos][1] == unheard and count > 20 and count< min(set1[-1])) or (SongDict[Curr_pos][1] == heard and count<min(set1[-1])):
		
#		RewardMatrix[Curr_pos][selected]+= jump(RewardMatrix)

#	else:
#		RewardMatrix[Curr_pos][selected]+=3 # for now we consider 3. later add the signals like Half listned or completely

#	rearrange_sets()

	
#def rearrange_sets():

	# find the 

		

def main():

	curr=0
	seq=[0,1,2,3,4,5,6,1,2,3,4,2,3,1,4,3,6,5,4,3,4,2,7,8,9,10,7,8,9,8,7,9,8,7,9,8,7,10] #morning data + evening data
	R = [[0.0 for j in range(len(list(set(seq))))]for i in range(len(list(set(seq))))] # initializing reward matrix to 0 and holds the reward values for evry transition
	R = array(R)
	v = [0.25 for i in range(len(list(set(seq))))] # Our policy factor . Basically Ranking the song based on the action n x 1 matrix
	v= mat(v)
	alpha = 1.0
	normalized = {}	
	c=0
	for i in range(len(seq)):
		selection= seq[c]#input("enter song index:")
		c+=1
        	reward = 3 #input("enter reward:")
		R= array(R)
		R[curr][selection]+=reward # r(t+1) next reward when i listen to curr completely and go to selected... make it a function 
	    	R=mat(R.copy()) # For converting R to matrix
	    	temp=R[curr]/R[curr].sum() # normalizing the current matrix 

	    	r =(0.85*temp)+(0.15/len(list(set(seq)))) # adding some damping factor to those which are not being listened
	    	normalized[curr]=r # for each song trying to determine the flow ,  i.e How one song leads to another  
	    	r= mat(r)
	    	v= mat(v)+(alpha*(mat(r) - (0.15*mat(v)))) # SARSA equation 
	    	alpha=1.0/(i+1) # reduce the learning rate iteratively
	    	curr=selection # change curr to selection
	    	print 'Current policy : {0} and Current Reward: {1} and Alpha:{2}'.format(v,R,alpha)
	    	v = v[0]/v[0].sum()

	populate_reward(R)	

			
	print 'POLICY MATRIX :{0}', format(v)

	for i,j in normalized.iteritems():
		print i,':',j


### FURTHER ADDITION : 
#1.Set-Transition-Randomization 
#2.Optimal-deletion 
#3.Freshness 
#4.Indexing   
if  __name__=='__main__':
	main()

