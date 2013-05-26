#!/usr/bin/python

from numpy import *
import operator
import random
import logging

logging.root.setLevel(logging.INFO)

SongDict = {}
NewSongDict = {} #Creating a dict for new songs as updation becomes simpler 
heard = 1
unheard = 0 #Newness 

#Our Sets
top50=[] 
next50=[]
new=[]

global used = 0;

def jump(RewardMatrix):
	n=size(RewardMatrix)
	cumilative = RewardMatrix.sum()
	Reward = log(cumilative*(n/(n+1)))
	return Reward 

def create_sets(playlist,RewardMatrix):

	for i in enumerate(RewardMatrix): #adding the song index as well as the score! index is the song's identity 
		new = list(new)
		top50= list(top50)
		next50= list(next50)

		if RewardMatrix[i[0]].sum() == 0: #If the song is unheard / New
			NewSongDict[i[0]]=0 #add the new song and the point=0
			logging.INFO('New Song \n')
		else:
				
			SongDict[i[0]]=RewardMatrix[i[0]].sum() #update the dict with new scores
			logging.INFO('Already Heard\n'.format(i[0]))
	
	HighestRewardList= sorted(SongDict.iteritems(), key=lambda x:x[1],reverse= True) #Based on Reward sort the SongDict
	new = sorted(NewSongDict.iteritems()) #basically returning a list of tupules with no repeatition or else have to use a loop to keep adding
	logging.INFO("Creating Sets\n")
	
	#Converting to set type
	top50=set(HighestRewardList[:((len(HighestRewardList)/2))-1])
	next50 = set(HighestRewardList[(len(HighestRewardList)/2):])
	new= set(new)
	logging.INFO('top50 next50 new--> sets are updated\n')
	
	for songs in HighestRewardList: #displaying the top songs
		print songs


def main():

	curr=0
	R = [[0.0 for j in range(4)]for i in range(4)]
	R = array(R)
	v = [0.25 for i in range(4)]
	v= mat(v)
	alpha=1.0
	normalised = {}

	for i in range(20):
		
		#converting the sets to list type so that the object doesnt throw an "indexing error"
		top50=list(top50)
		next50=list(next50)
		new=list(new)

		selection= input('enter song index:')
		logging.INFO('{0} added to playlist'.format(selection))
		#Assuming we have used the playlist quite a no of times and songs belonging to the lower sets or even the top50 set with their reward value less the half of the max reward we start using the log function
		if (used > 10) and  ((SongDict[curr] in new) or (SongDict[curr] in next50) or (SongDict[curr] in top50)) and (SongDict[curr]<top[0][1]/2 ):
			R=array(R)
			R[curr][selection]+=jump(R) #Jump greater than usual
		
		else:
			reward = random.randint(0,3) #Random assignment of rewards
			R= array(R)
			R[curr][selection]+=reward
	    	R=mat(R.copy())
	    	temp=R[curr]/R[curr].sum()

	    	r = (0.85*temp)+(0.15/4) #adding the damping factor
		normalised[curr]=r
	    	r= mat(r)
	    	v= mat(v)+(alpha*(mat(r) - (0.15*mat(v)))) # The Learning algo
	    	alpha=1.0/(i+1)
	    	curr=selection
	    	print 'Current policy : {0} and Current Reward: {1} and Alpha:{2}'.format(v,R,alpha)
	    	v = v[0]/v[0].sum()
		used +=1 #Incrementing the no of times the player has been used to determine if the log fuction can be used or not
		create_sets(R) 
	
	print 'POLICY MATRIX :{0}'.format(v)
	
	for i,j in normalised.iteritems():
		print i,':',j #printing the flow pattern



if  __name__=='__main__':
	main()

