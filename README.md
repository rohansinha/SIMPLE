## SIMPLE - THE NEXT MUSIC PLAYER 

1. Each team should have a fork of this repository
2. Team members should clone from the fork
3. Create a branch ```submission/<Team Name>```
4. Make a folder with your ```<Project name>``` in the branch
5. Work inside your ___Project folder___, Commit changes and push to the branch ```git push origin submission/<Team Name>```
6. After completing the hack ,each team must send a **Pull request** to merge the Branch

theta0 theta1 theta2 : behaviour of each element on x0,x1 and x2

#Weather
1.songs not heard : Initial prediction based on **genre** and the music learner equation
2.Same song will be rated differently on different weather occasions

It will be better to keep track of genre: more preference to genre over artist

3.Later, we can have a "General Mode" : where songs will be predicted purely on the basis of how the user reacts to the song till now
its independent of time

4.other **Climate Mode** : User listens to certain no of songs. Many songs are not heard yet . **SIMPLE** understands the features of the song heard during that climate mode.

#Confusion 
Rain can have "3 parameters" ...each parameter will have 3 other internal parameters : [np1,np2,np3][genre,artist,heard]
club these parameters into 1 and we obtain one parameter :D

#Future Prediction Analysis
1.use logistic regression to predict the song u havent rated and measure its potential : Each Song is identified by its :[genre,artist,heard].
2.push that rating to the global policy for that weather.
3.Live audio streaming : based on correlation of interest.  
