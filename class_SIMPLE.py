#!/usr/bin/python


""" 
SIMPLE ->
	Machine learning concept
	An intelligent rating mechanism based on users response to the player
	It is divided into two parts:
		1. History Function
		2. Trending Funtion
	1. History Function(its too specific) :
		It maintains a record of how the user reacts to the next song after listening to 10 or 50 or 80% of the song.
		If the user listens to 50% of A and transits to B and listens 80% of it. 
			Then A's 50% matrix is updated at B's index by B's reward points
			Hence it means usually after listening to 50% of A user would prefer listening to B
	2. Trending Function:
		It maintains a record of how the user is reacting with the current song irrespective of its past
		If user listens to 50% of A and transits to B 
		 	Then Global reward matrix for B,A is updated to reward points for listening to 50% A
			column : source
			row : destination
"""
from numpy import *
from uuid import *
from time import *
from random import *
import logging

logging.root.setLevel(logging.INFO)
logging.basicConfig(filename='example.log',filemode='w',level=logging.INFO)

table = {} # key : Song_Name   value: uuid4(),class itself

class SongException(Exception):
	def init(self,value,mesg):
		self.val = value
		self.mesg = mesg

	def str(self):
		return repr(self.mesg)


class Song(object):
	
	alpha = 1    #apha doesnt change
	gamma = 0.85 #gamma doesnt change
	used = 0     #static counter which keeps track of the number of times the player was used 
	index =0     #static counter of each song in the matrix

	def __init__(self,n,name,duration):
		
		d = SongException(1,'Song already exists')
		if name not in table:
			self.name = name #name of the song
			self.duration = duration+0.0 #duration of the song
			self.v10 = array([1.0/n for i in range(n)])
			self.v50 = array([1.0/n for i in range(n)])
			self.v80 = array([1.0/n for i in range(n)])
			self.r10 = array([0.0 for i in range(n)])
			self.r50 = array([0.0 for i in range(n)])
			self.r80 = array([0.0 for i in range(n)])
			
			self.INDEX = Song.index
			Song.index+=1 #incrementing the index everytime 
			self.flag = False #setting flag to unheard
			self.hearing = 0.0
			table[name] = self #setting the uuid of the song
		
		else:
			raise d #if the song already exist in the playlist


	def play(self):
		
		#d = SongException(1,'Song already exists')
		#if self.flag:
		#	raise d
		
		h = SongException(2,'Song already heard')
		if Song.used==0:
			temp= input('The player is being used the first time \n How much have you heard%:')
			per = (temp/self.duration)*100
			if per>0 and per<50:
				self.hearing = 10
			elif per>=50 and per<80:
				self.hearing = 50
			else:
				self.hearing = 80

		logging.info('You are hearing {0} and have heard {1}'.format(self.name,self.hearing))
		
		self.next_song = raw_input('Enter the next song:')
		self.next_state = table[self.next_song][1]
		
		if self.next_state.flag: #check if the next song is heard or not 
			raise h
		else:
			logging.info('Listening to {0}'.format(self.next_state.name))
		
		print ' Duration of {0}: {1}'.format(self.next_state.name,self.next_state.duration)
		mins = input('How much have you heard:')+0.0
		per = (mins/self.next_state.duration)*100
		print 'Per :{0}'.format(per)
		
		if per>=0 and per<50:
			self.next_state.hearing = 10
	
		elif per>=50 and per<80:
			self.next_state.hearing = 50
		
		elif per>=80 and per<=100:
			self.next_state.hearing = 80
		
		self.update(per,self.next_state.INDEX) #update the learner . Passing the %heard and the index of the song
		Song.used+=1
		self.flag = True #Song heard 
	

	def Learner(self,pos,per):
		pass

	def update(self,per,pos):
		
		print 'THE POS IS {0} and Hearing is {1} and per of next song {2}'.format(pos,self.hearing,per)	
		d = SongException(3,'Hearing not set properly ')
		if Song.used<50:
			#*************************************when the user hears 10% of the song*****************************
			if self.hearing == 10:
				if per>=0 and per<50:
					self.r10[pos]+=0

					if not self.r10.sum()<1:
						self.r10 = self.r10/sqrt(self.r10.sum())
					change = self.r10 + (Song.gamma * self.v10)
					expected = change - self.v10 
					self.v10 += (Song.alpha * expected)
					self.v10 = self.v10/self.v10.sum()
					logging.info('The Reward {0} \n The v10 = {1}'.format(self.r10,self.v10))
	
				elif per>=50 and per<80:	
					self.r10[pos]+=3	

					self.r10 = self.r10/sqrt(self.r10.sum())	
					change = self.r10 + (Song.gamma * self.v10)
					expected = change - self.v10 
					self.v10 += (Song.alpha * expected)
					self.v10 = self.v10/self.v10.sum()
					logging.info('The Reward {0} \n The v10 = {1}'.format(self.r10,self.v10))
					 	
				else:
				
					self.r10[pos]+=5
					self.r10 = self.r10/sqrt(self.r10.sum())
					change = self.r10 + (Song.gamma * self.v10)
					expected = change - self.v10 
					self.v10 += (Song.alpha * expected)
					self.v10 = self.v10/self.v10.sum()
	
					logging.info('The Reward {0} \n The v10 = {1}'.format(self.r10,self.v10))
				
			# ***************************************** when the the user hears 50% of the song ********************
			elif self.hearing==50:
				#self.Learner(self.r50,pos,per,self.v50)
		
				if per>=0 and per<50:
					self.r50[pos]+=0
					if not self.r50.sum()<1:
						self.r50 = self.r50/sqrt(self.r50.sum())
					
					change = self.r50 + (Song.gamma * self.v50)
					expected = change - self.v50 
					self.v50 += (Song.alpha * expected)
					self.v50 = self.v50/self.v50.sum()
					logging.info('The Reward {0} \n The v50 = {1}'.format(self.r50,self.v50))
	
				elif per>=50 and per<80:
							
					self.r50[pos]+=3	
					self.r50 = self.r50/sqrt(self.r50.sum())
					change = self.r50 + (Song.gamma * self.v50)
					expected = change - self.v50 
					self.v50 += (Song.alpha * expected)
					self.v50 = self.v50/self.v50.sum()
					logging.info('The Reward {0} \n The v50 = {1}'.format(self.r50,self.v50))
					 	
				else:
				
					self.r50[pos]+=5
					self.r50 = self.r50/sqrt(self.r50.sum())
					change = self.r50 + (Song.gamma * self.v50)
					expected = change - self.v50
					self.v50 += (Song.alpha * expected)
					self.v50 = self.v50/self.v50.sum()

					logging.info('The Reward {0} \n The v50 = {1}'.format(self.r50,self.v50))

#************************************************************when the user listens to 80% *********************************************
					
			elif self.hearing == 80:
				#self.Learner(self.r80,pos,per,self.v80)
		
				if per>=0 and per<50:
					self.r80[pos]+=0

					if not self.r80.sum()<1:
						self.r80 = self.r80/sqrt(self.r80.sum())
						
					change = self.r80 + (Song.gamma * self.v80)
					expected = change - self.v80 
					self.v80 += (Song.alpha * expected)
					self.v80 = self.v80/self.v80.sum()
					logging.info('The Reward {0} \n The v80 = {1}'.format(self.r80,self.v80))
	
				elif per>=50 and per<80:
						
					self.r80[pos]+=3	
					self.r80 = self.r80/sqrt(self.r80.sum())
				
					change = self.r80 + (Song.gamma * self.v80)
					expected = change - self.v80 
					self.v80 += (Song.alpha * expected)
					self.v80 = self.v80/self.v80.sum()
					logging.info('The Reward {0} \n The v80 = {1}'.format(self.r80,self.v80))
					 	
				else:
				
					self.r80[pos]+=5
					self.r80 = self.r80/sqrt(self.r80.sum())
				
					change = self.r80 + (Song.gamma * self.v80)
					expected = change - self.v80 
					self.v80 += (Song.alpha * expected)
					self.v80 = self.v80/self.v80.sum()
					logging.info('The Reward {0} \n The v80 = {1}'.format(self.r80,self.v80))
			
			else:
				raise d

 
class Brainy_Song(object):
		
		def __init__(self,curr): #pass the starting song 
			
			h = SongException(3,'Song doesnot exist in the playlist\n')
			epsilon = 0.7
			if curr not in table:
				raise h
			else:
				logging.info('Global Reward Matrix and Policy Matrix generated\n')
				self.current = curr #current song name
				Brainy_Song.R = [[0.0 for j in range(len(table))] for i in range(len(table))]
				Brainy_Song.R = array(Brainy_Song.R)
				Brainy_Song.v = array([1.0/len(table) for i in range(len(table))])
				Brainy_Song.r = []
				Brainy_Song.gamma = 0.85 # Wont change. Lets see if both classes actually need the same gamma or not
				Brainy_Song.alpha = 1.0 #alpha will decay accordingly and will be reset everytime user resets the player
		
	
		def predict(self):
			temp = random()
			if temp < Brainy_Song.epsilon:
				#predicted_index = Brainy_Song.index(max(Brainy_Song.v[0]))
				best_unflagged = sorted([(Brainy_Song.v[table[i].INDEX],table[i].INDEX) for i in table.iterkeys() if not table[i].flag],reverse = True) #Storing the unheard songs
				print 'According to Global Policy Training The predicted song is {0}' .format(best_unflagged[0][1]) #Displaying the index

			else:
				heard = self.hearing 
				if heard>=0 and heard<50:
					best_unflagged = sorted([(table[i].v10,table[i].INDEX) for i in table.iterkeys() if not table[i].flag],reverse = True)
				
				elif heard>=50 and heard<80:
					best_unflagged = sorted([(table[i].v50,table[i].INDEX) for i in table.iterkeys() if not table[i].flag],reverse = True)
				
				else :
					best_unflagged = sorted([(table[i].v80,table[i].INDEX) for i in table.iterkeys() if not table[i].flag],reverse = True)
				print 'According to THE HISTORIC LEARNING EXPERIENCE .. the prediction is {0}'.format(best_unflagged[0][1])

		def run(self):
			current = self.current
			print 'Listening to {0}:'.format(current)
			table[current].play()
			hearing = table[current].hearing+0.0 #deciding how much the song will be rewarded
			duration = table[current].duration 
			per = hearing
			curr_index = table[current].INDEX  #Index of the current song 
			
			while 1:
				#Here we add the prediction module 
					

				next_song_index = table[current].next_state.INDEX #the the position of the song in the matrix
				
				if per>=0 and per<=10:
					Brainy_Song.R[next_song_index][curr_index]+=0
				elif per>10 and per<80:
					Brainy_Song.R[next_song_index][curr_index]+=3
				else:
					Brainy_Song.R[next_song_index][curr_index]+=5
				
				Brainy_Song.r = []
				
				temp = Brainy_Song.R.copy() #taking only the copy of the matrix  
				
				for i in range(len(table)):
					
					if Brainy_Song.R[:,i].sum()<=0:
						continue
					temp[:,i] = Brainy_Song.R[:,i]/sqrt(Brainy_Song.R[:].sum())
				
				for i in range(len(table)):
					Brainy_Song.r.append(temp[:,i].sum()) #will normalize later 
	
				Brainy_Song.r = array(Brainy_Song.r)

				change = (Brainy_Song.r + (0.85 * Brainy_Song.v)) - Brainy_Song.v
				expected = Brainy_Song.alpha * change
				Brainy_Song.v+=expected
				Brainy_Song.v = Brainy_Song.v/Brainy_Song.v.sum()	
				curr_index = next_song_index
				current = table[current].next_song # current song becomes the the current song's next song 
				
				print 'The reward Matrix {0}\n'.format(Brainy_Song.r)
				print 'Global learning policy {0}\n'.format(Brainy_Song.v)
				print '2D matrix {0}\n'.format(Brainy_Song.R)
			
				hearing = table[current].hearing+0.0
				table[current].play() #the current song name is the key of the table 
				duration = table[current].duration
				per = hearing
				print 'Current Song :{0} \n Percent: {1} \n Hearing:{2} \n Duration:{3}'.format(current,per,hearing,duration)	
				
				
