#!/usr/bin/python

from numpy import *

def Threshold_crossed()
	

def jump(RewardMatrix):
	n=size(RewardMatrix)
	cumilative = RewardMatrix.sum()
	Reward = log(cumilative*(n/(n+1)))
	return Reward 
def main():

	curr=0
	R = [[0.0 for j in range(4)]for i in range(4)]
	R = array(R)
	v = [0.25 for i in range(4)]
	v= mat(v)
	alpha=1.0
	for i in range(20):
	    selection= input("enter song index:")
	    reward = input("enter reward:")
	    R= array(R)
	    R[curr][selection]+=reward
	    R=mat(R.copy())
	    temp=R[curr]/R[curr].sum()

	    r = (0.85*temp)+(0.15/4)
	    r= mat(r)
	    v= mat(v)+(alpha*(mat(r) - (0.15*mat(v))))
	    alpha=1.0/(i+1)
	    curr=selection
	    print 'Current policy : {0} and Current Reward: {1} and Alpha:{2}'.format(v,R,alpha)
	    v = v[0]/v[0].sum()
	
	print 'POLICY MATRIX :{0}'.format(v)

if  __name__=='__main__':
	main()

