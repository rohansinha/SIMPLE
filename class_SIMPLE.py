#!/usr/bin/python
from numpy import *
from uuid import *
import logging

logging.root.setLevel(logging.INFO)
logging.basicConfig(filename='example.log',filemode='w',level=logging.INFO)

table = {} # key : Song_Name   value: uuid4(),class itself

class SongException(Exception):
	def __init__(self,value,mesg):
		self.val = value
		self.mesg = mesg

	def __str__(self):
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
			self.__v10 = array([0.0 for i in range(n)])
			self.__v50 = array([0.0 for i in range(n)])
			self.__v80 = array([0.0 for i in range(n)])
			self.__r10 = array([0.0 for i in range(n)])
			self.__r50 = array([0.0 for i in range(n)])
			self.__r80 = array([0.0 for i in range(n)])
			self.INDEX = Song.index
			Song.index+=1 #incrementing the index everytime 
			self.flag = False #setting flag to unheard
			self.hearing = 0.0
			table[name] = [uuid4(),self] #setting the uuid of the song
		else:
			raise d #if the song already exist in the playlist


	def play(self):
		
		#d = SongException(1,'Song already exists')
		#if self.flag:
		#	raise d
		if Song.used==0:
			self.hearing = input('The player is being used the first time \n How much have you heard:')
		
		logging.info('You are hearing {0} and have heard {1}'.format(self.name,self.hearing))
		self.next_song = raw_input('Enter the next song:')
		self.next_state = table[self.next_song][1]
		h = SongException(2,'Song already heard') #import a timing module and unflag it 
		
		if self.next_state.flag: #check if the next song is heard or not 
			raise h
		else:
			logging.info('Listening to {0}'.format(self.next_state.name))
		
		print ' Duration of {0}: {1}'.format(self.next_state.name,self.next_state.duration)
		mins = input('How much have you heard:')+0.0
		per = (mins/self.next_state.duration)*100
		print 'Per :{0}'.format(per)
		
		if per>0 and per<50:
			self.next_state.hearing = 10
		elif per>=50 and per<80:
			self.next_state.hearing = 50
		elif per>=80 and per<=100:
			self.next_state.hearing = 80
		
		self.update(per,self.next_state.INDEX) #update the learner . Passing the %heard and the index of the song
		Song.used+=1
		#self.flag = True #Song heard 
	
	
	def update(self,per,pos):
		
		if Song.used<50:
			if per>0 and per<=10:
				
				logging.info('Heard only 10% of the song')
				self.__r10[pos]+=-1
				self.__r10 = self.__r10/self.__r10.sum()
				
				self.change = self.__r10 + Song.gamma * self.__v10
				self.expected = self.change - self.__v10 
				self.__v10 += Song.alpha * self.expected
				logging.info('The Reward {0} \n The v10 = {1}'.format(self.__r10,self.__v10))

			elif per>10 and per<80:
				self.__r50[pos]+=3	
				self.__r50 = self.__r50/self.__r50.sum()
				
				self.change = self.__r50 + Song.gamma * self.__v50
				self.expected = self.change - self.__v50 
				self.__v50 += Song.alpha * self.expected
				logging.info('The Reward {0} \n The v50 = {1}'.format(self.__r50,self.__v50))
				 
				
			elif per>=80:
				self.__r80[pos]+=5
				self.__r80 = self.__r80/self.__r80.sum()
				
				self.change = self.__r80 + Song.gamma * self.__v80
				self.expected = self.change - self.__v80 
				self.__v80 += Song.alpha * self.expected
				logging.info('The Reward {0} \n The v80 = {1}'.format(self.__r80,self.__v80))

#table has the required contents of the song 
class Brainy_Song(object):
		
		def __init__(self,curr): #pass the starting song 
			
			h = SongException(3,'Song doesnot exist in the playlist\n')
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
		
		def run(self):
			
			print 'Listening to {0}:'.format(self.current)
			table[self.current][1].play()
			self.hearing = table[self.current][1].hearing+0.0 #deciding how much the song will be rewarded
			self.duration = table[self.current][1].duration 
			self.per = (self.hearing/self.duration)*100
			self.curr_index = table[self.current][1].INDEX  #Index of the current song 
			while 1:
				
				
				self.next_song_index = table[self.current][1].next_state.INDEX #the the position of the song in the matrix
				
				if self.per>0 and self.per<=10:
					Brainy_Song.R[self.next_song_index][self.curr_index]+=-1
				
				elif self.per>10 and self.per<=50:
					Brainy_Song.R[self.next_song_index][self.curr_index]+=3
				
				else:
					Brainy_Song.R[self.next_song_index][self.curr_index]+=5
				
				Brainy_Song.r = []
				
				temp = Brainy_Song.R 
				
				#temp stores the temporary normalized matrix
				for i in range(len(table)):
					
					if Brainy_Song.R[:,i].sum()==0:
						continue
					temp[:,i] = Brainy_Song.R[:,i]/Brainy_Song.R[:,i].sum()
				
				print 'Showing temp {0}'.format(temp)
				for i in range(len(table)):
					Brainy_Song.r.append(temp[:,i].sum()) #will normalize later 
					#Brainy_Song.r.append(Brainy_Song.R[i,self.curr_index]/Brainy_Song.R[:,self.curr_index].sum())
					#Brainy_Song.r.append(Brainy_Song.R[:,i]/Brainy_Song.R[:,self.curr_index].sum())
					logging.info('Normalised Brainy matrix :{0}'.format(Brainy_Song.r))
	
				Brainy_Song.r = array(Brainy_Song.r)

				change = (Brainy_Song.r +0.85 * Brainy_Song.v) - Brainy_Song.v
				expected = Brainy_Song.alpha * change
				#Brainy_Song.v += expected
				Brainy_Song.v+=expected
				
				self.curr_index = self.next_song_index
				self.current = table[self.current][1].next_song # current song becomes the the current song's next song 
				
				print 'The reward Matrix {0}\n'.format(Brainy_Song.r)
				print 'Global learning policy {0}\n'.format(Brainy_Song.v)
				print '2D matrix {0}\n'.format(Brainy_Song.R)
			
				self.hearing = table[self.current][1].hearing+0.0
				table[self.current][1].play() #the current song name is the key of the table 
				self.duration = table[self.current][1].duration
				self.per = (self.hearing/self.duration)*100
				
				#add the prediction module 
