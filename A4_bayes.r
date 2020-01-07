#	#Solution to Question 2
#	#Solved with (rethinking) library that creates models using Hamiltonian algorithm (STAN)

library(rethinking)
theta = 0.4 	  #Define theta
sigma = 30		  #Define sigma
x <- runif(30,0,1500)  						#Generate 30 points for x between 0 and 1500
y <- (theta*x) + sigma 						#Generate 30 points of y using formula
#Synthetic data generation complete	

d <- data.frame(y,x) 						#Create a data frame to be used in map2stan model
	
model1.q2 <- map2stan(						#map2stan model which samples using Hamiltonian algorithm
    alist(									#Model only accepts data in form of lists
        y ~ dnorm(mu1,sigma1),				#The likelihood function
        mu1 <- theta*x,						#The linear regression model equation
        theta ~ dnorm(0,10000),				#Prior information of theta - very weak prior
		sigma1 <- 30						#Assuming that we know sigma
    ),
    data=d, start=list(theta=0),			#Referring the synthetic dataset we created earlier. Giving start value to theta
	chains=1, iter=10000,warmup=5000		#10,000 iterations with 5000 warm-up period
)
post.samples <- extract.samples(model1.q2, n=5000) 	#Extracts samples from the posterior distribution
theta <- post.samples[["theta"]] 			#Take out theta from post data frame
plot(theta)									#Scatter plot of theta samples
dev.copy(png, 'Theta Samples M1Q2.png') 	#Save the plot
dev.off()
dens(theta)									#Density plot of theta samples
dev.copy(png, 'Theta Density M1Q2.png') 	#Save the plot
dev.off()

#	#Now running the model with a very narrow prior
model2.q2 <- map2stan(						#map2stan model which samples using Hamiltonian algorithm
    alist(									#Accepts data in form of lists
        y ~ dnorm(mu1,sigma1),				#The likelihood function
        mu1 <- theta*x,						#The linear regression model equation
        theta ~ dnorm(0.5,0.3),				#Prior information of theta - very weak prior
        sigma1 <- 30						#Assuming that we know sigma
    ),			
    data=d, start=list(theta=0),			#Referring the synthetic dataset we created earlier
	chains=1, iter=10000,warmup=5000		#10,000 iterations with 5000 warm-up period
)
post2.samples <- extract.samples(model2.q2, n=5000) #Extracts samples from the posterior distribution
theta2 <- post2.samples[["theta"]] 			#Take out theta from post data frame
plot(theta2)								#Scatter plot of theta samples
dev.copy(png, 'Theta Samples M2Q2.png') 	#Save the plot
dev.off()
dens(theta2)								#Density plot of theta samples
dev.copy(png, 'Theta Density M2Q2.png') 	#Save the plot
dev.off()

#Question 2 solved  #################################################################

#	#Question 4 - follow up with same data generated in question 2
xf <- runif(100,0,1000)						#Generate hundred random points between 0 and 1000
theta.med <- median(theta)					#Get median of theta
theta.lower= quantile(theta,0.025)          #Get lower 95th interval of theta
theta.upper= quantile(theta,0.975)          #Get upper 95th interval of theta
yf.med <- (theta.med*xf) + sigma            #Generate 100 posterior predictive values with median
yf.lower <- (theta.lower*xf) + sigma 	    #Generate 100 posterior predictive values with lower quantile
yf.upper <- (theta.upper*xf) + sigma 	 	#Generate 100 posterior predictive values with upper quantile
plot(xf,yf.med)								#Plot median data points
lines(xf,yf.med,col="blue")                 #Plot line on median points
lines(xf,yf.lower,col="red")                #Plot lower credibility interval line
lines(xf,yf.upper,col="red")                #Plot upper credibility interval line
dev.copy(png, 'Uncertainty Q4.png') 		#Save the plot
dev.off()
qqnorm(yf.med)								#Generate the Q-Q plot. The function does the whole work of setting up a random normal distribution itself.	
dev.copy(png, 'QQPlot Q4.png') 				#Save the plot
dev.off()

#Question 4 solved  #################################################################

#	#Question 5
xf.new <- runif(100,1200,2000)
yf.med.new <- (theta.med*xf.new) + sigma            #Generate 100 posterior predictive values with median
yf.lower.new <- (theta.lower*xf.new) + sigma 	    #Generate 100 posterior predictive values with lower quantile
yf.upper.new <- (theta.upper*xf.new) + sigma 		#Generate 100 posterior predictive values with upper quantile
plot(xf.new,yf.med.new)								#Plot median data points
lines(xf.new,yf.med.new,col="blue")                 #Plot line on median points
lines(xf.new,yf.lower.new,col="blue")               #Plot lower credibility interval line
lines(xf.new,yf.upper.new,col="blue") 				#Plot upper credibility interval line
dev.copy(png, 'Uncertainty Q5.png') 			#Save the plot
dev.off()
qqnorm(yf.med.new)
dev.copy(png, 'QQPlot Q5.png') 					#Save the plot
dev.off()	 

#Question 5 solved  #################################################################

#	#Question 9

x = 1910									#Observed Data
d <- data.frame(x)							#Create data frame

model1.q9 <- map2stan(						#Stan Model
    alist(
        y ~ dnorm(theta,sigma1),			#Likelihood
        theta ~ dnorm(1850,30),				#Prior
        sigma1 <- 40						#Known sigma
    ),
    data=d, start=list(theta=0),
	chains=1, iter=10000,warmup=5000		#10,000 iterations with 5000 warm-up period	
)

#Extract samples and save plots
post3.samples <- extract.samples(model1.q9, n=5000)
theta3 <- post3.samples[["theta"]] 			
plot(theta3)								
dev.copy(png, 'Theta Samples M1Q9.png') 	
dev.off()
dens(theta3)								
dev.copy(png, 'Theta Density M1Q9.png') 	
dev.off()
y1 <- post3.samples[["y"]] 			
plot(y1)								
dev.copy(png, 'y Samples M1Q9.png') 	
dev.off()
dens(y1)								
dev.copy(png, 'y Density M1Q9.png') 	
dev.off()

#2nd model with the other prior
model2.q9 <- map2stan(						#Stan Model
    alist(									
        y ~ dnorm(theta,sigma1),            #Likelihood
        theta ~ dnorm(1850,70),             #Prior
        sigma1 <- 40                        #Known sigma
    ),                                      
    data=d, start=list(theta=0),                                
	chains=1, iter=10000,warmup=5000        #10,000 iterations with 5000 warm-up period
)

#Extract samples and save plots
post4.samples <- extract.samples(model2.q9, n=5000)
theta4 <- post4.samples[["theta"]] 			
plot(theta4)								
dev.copy(png, 'Theta Samples M2Q9.png') 	
dev.off()
dens(theta4)								
dev.copy(png, 'Theta Density M2Q9.png') 	
dev.off()
y2 <- post4.samples[["y"]] 			
plot(y2)								
dev.copy(png, 'y Samples M2Q9.png') 	
dev.off()
dens(y2)								
dev.copy(png, 'y Density M2Q9.png') 	
dev.off()

#Question 9 solved  #################################################################

#Question 6
x <- runif(30,0,1500) #Generate random observations
sigma = 30 #Define sigma
prior <- function(theta) dnorm(theta,mean = 0,sd = 10000) #Define prior density
lkhood <- function(theta) dnorm(theta*x, sigma) #Define likelihood function
post <- function(theta) ifelse(theta>=0 && theta <=1, prior(theta)*lkhood(theta),0) #Define posterior function
iter = 10000 #Define number of iterations of chain
theta_chain <- rep(NA,iter) #Create NA vector for storing theta values
theta_chain[1] <- 0 #Starting point of chain
for (i in 1:(iter-1)) {	
	proposal <- rnorm(1,mean=theta_chain[i],sd=0.01) #Proposal distribution
	U <- runif(1) #Uniform distribution
	check <- min(c(1,(post(proposal)/post(theta_chain[i])))) #Calculate ratio of probabilities of current and next point
	if(U<=check){ #Check if random uniform probability less than above ratio
	theta_chain[i+1] <- proposal #If less, reject the sample
	} else {
			theta_chain[i+1] <- theta_chain[i] #If ratio > random probability, accept the sample
	}
}
theta_chain <- tail(theta_chain,iter/2) #Discard first half of chain as burn-in period

plot(theta_chain)	 #Plot the chain
dev.copy(png, 'Theta Chain M1Q6.png') #Save the plot
dev.off()

dens(theta_chain)	 #Density plot of the chain
dev.copy(png, 'Theta Density M1Q6.png') #Save the plot
dev.off()

#Question 6 solved  #################################################################

#Question 8
x.q7 <- runif(100,0,1000)						#Generate hundred random points between 0 and 1000
theta.med.q7 <- median(theta_chain)					#Get median of theta
theta.lower.q7= quantile(theta_chain,0.025)          #Get lower 95th interval of theta
theta.upper.q7= quantile(theta_chain,0.975)          #Get upper 95th interval of theta
yf.med.q7 <- (theta.med.q7*x.q7) + sigma            #Generate 100 posterior predictive values with median
yf.lower.q7 <- (theta.lower.q7*x.q7) + sigma 	    #Generate 100 posterior predictive values with lower quantile
yf.upper.q7 <- (theta.upper.q7*x.q7) + sigma 	 	#Generate 100 posterior predictive values with upper quantile
plot(x.q7,yf.med.q7)								#Plot median data points
lines(x.q7,yf.med.q7,col="blue")                 #Plot line on median points
lines(x.q7,yf.lower.q7,col="red")                #Plot lower credibility interval line
lines(x.q7,yf.upper.q7,col="red")                #Plot upper credibility interval line
dev.copy(png, 'Uncertainty Q7.png') 		#Save the plot
dev.off()
qqnorm(yf.med.q7)								#Generate the Q-Q plot. The function does the whole work of setting up a random normal distribution itself.	
dev.copy(png, 'QQPlot Q7.png') 				#Save the plot
dev.off()

#Question 8 solved  #################################################################

