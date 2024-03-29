#!/usr/bin/python


from numpy import *
from dataset import *
import operator
import random
import logging
 

logging.root.setLevel(logging.INFO)

def jump(RewardMatrix):
	n=size(RewardMatrix)
	n=n+0.0
	cumilative = RewardMatrix.sum()
	Reward = log(cumilative*(n/(n+1)))
	return Reward 

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


def xyz(curr,R,v):

	global top50,next50,new,used
	R = array(R)
	v= mat(v)
	alpha=1.0
	normalised = {}
	
	for i in range(16): #16 times
		
		#converting the sets to list type so that the object doesnt throw an "indexing error"
		top50=list(top50)
		next50=list(next50)
		new=list(new)

		selection= input('enter song index:')
		logging.info('{0} added to playlist queue and  SongDict[{1}]:{2} and top50={3}'.format(str(selection),curr,SongDict.get(curr),top50))
		#Assumin we have used the playlist quite a no of times and songs belonging to the lower sets or even the top50 set with their reward value less the half of the max reward we start using the log function
		if (used > 10) and (SongDict.get(curr)<top50[0][1]/2 ):
			R=array(R)			
			R[selection][curr]+=jump(R) #Jump greater than usual
			logging.info('jumping by some reward {0}\n'.format(jump(R)))	
		else:

			logging.info('LISTENING TO {0} and TRANSITION TO {1}'.format(curr,selection))
			reward = input('enter reward :')
			R= array(R)
			R[selection][curr]+=reward
	    	R=mat(R.copy())
		logging.info('Value of R[curr] and R[curr].sum()={0}\t{1}'.format(R[curr],R[curr].sum()))
	    	r= []
		for i in range(5):
			r.append(R[:,i].sum()/R[:].sum()) #Normalised 

		r = mat(r)
		
		print 'r {0}'.format(r)
	    	v= mat(v)+(alpha*(mat(r) - (0.15*mat(v)))) # The Learning algo
	    	curr=selection
	    	print 'Current policy : \n{0} and Current Reward: \n{1} and Alpha:{2}'.format(v,R,alpha)
	    	v = v[0]/v[0].sum()
		used +=1 #Incrementing the no of times the player has been used to determine if the log fuction can be used or not
		create_sets(R) 
	
	print 'POLICY MATRIX :{-1}'.format(v)
	
	for i,j in normalised.iteritems():
		print i,':',j #printing the flow pattern


def main():
	play=input('Press 1 to enter SIMPLE:')
	R = [[0.0 for j in range(5)]for i in range(5)] #0.0 10
	v = [0.2 for i in range(5)] # 0.1 10
	while play:
		curr=input('Enter song index:')
	
		xyz(curr,R,v)
		choice=raw_input('Enter SIMPLE again (y/n):')
		if choice=='n':
			break
	print 'SIMPLE TERMINATED. IT WAS A PLEASURE UNDERSTANDING YOU :)'
		
if  __name__=='__main__':
	main()

