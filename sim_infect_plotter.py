# All results of this script are available in the LaTex document.
# This script is not stand-alone, it needs input from the main script.
# I put this in a different file so that whoever is marking doesnt get confused by all this extra code. 
# If you want to run this, run the main script 'Assign2.py' first in your environment.

def fix_p_cure(n, p_cure):
    """
    This will cover the first answer out of the  
    total 4 in analysis part.
    p_infect is varied inside the function from low to high. 
    This will give a good idea of how variation in p_infect 
    affects results. 
    
    :param n: number of times the end of world simulation has to run
    :param p_cure: probability to cure a city
    
    :return fig: A figure showing the average number 
                of outbreaks it took to end the world for every possible 
                combination of fixed p_cure and varying p_infect
    """
    p_infect_array = numpy.linspace(0.1,0.9,9) ## Create an array of probabilities for p_infect to loop over to see variation in output
    store_data = [] ## Initializing an empty variable to store loop results
    avg_outbreaks = [] ## Variable to store the average outbreaks per scenario
    for p_infect in p_infect_array: ## Loop p_infect over the array we created
        n_iter = end_world_many_times(n, p_infect, p_cure) ## Number of outbreaks it took to end the world
        avg_outbreaks.append(int(numpy.mean(n_iter))) ## Append average number of outbreaks into empty list
        store_data.append(n_iter) ## Append whole list into empty list 
    
		##  Here I use two different plotting strategies. One for when p_cure = 0 
		##  and other for when it is anything other than 0. 
		##  This is because, anytime p_cure and p_infect get close to each other 
		##  like p_infect = 0.1 and p_cure = 0.05, they take a huge number of 
		##  simulations to end the world as compared to other scenarios. 
		##  This makes them visually unreadable on a normal scale so I used 
		##  logarithmic scale to display them.
    
        import seaborn as sns
        import pandas as pd
        import matplotlib.pyplot as plt
        import numpy as np
    if p_cure != 0:
        plt.hlines(y=p_infect_array, xmin=0, xmax=avg_outbreaks, color='skyblue')
        plt.xscale('log') ## Logarithmic y scale
        plt.plot(avg_outbreaks, p_infect_array, "o")
        plt.ylabel('p_infect')
        plt.xlabel('Average Number of outbreaks on Logarithmic Scale')
        for i,v in enumerate(avg_outbreaks): ## Annotating the total of each bar on top of the bar for better interpretation of results
                plt.text(int(avg_outbreaks[0] + 0.8*avg_outbreaks[0]),(i/10)+0.1,str(avg_outbreaks[i]), color='black', fontweight='bold')
        plt.title('Average number of outbreaks to take over the world. \n Fixed p_cure = %2.2f' %float(p_cure)) ## Plot title
    else:
        ## Same procedure as above but now with a normal scale instead of logarithmic
        plt.hlines(y=p_infect_array, xmin=0, xmax=avg_outbreaks, color='skyblue')
        plt.plot(avg_outbreaks, p_infect_array, "o")
        plt.ylabel('p_infect')
        plt.xlabel('Average Number of outbreaks')
        for i,v in enumerate(avg_outbreaks): ## Annotating the total of each bar on top of the bar for better interpretation of results
                plt.text(int(avg_outbreaks[0] + 0.1*avg_outbreaks[0]),(i/10)+0.1,str(avg_outbreaks[i]), color='black', fontweight='bold')
        plt.title('Average number of outbreaks to take over the world. \n Fixed p_cure = %2.2f' %float(p_cure)) ## Plot title
    
    return(store_data)    


def dens_plot(ans1, p_cure):
    for i in range(0,len(ans1)):
        sns.distplot(ans1[i], hist = False, kde = True,
                 kde_kws = {'linewidth': 1}, label = (i+1)/10)
    plt.legend(prop={'size': 12}, title = 'p_infect')
    plt.title('Density Plot of total outbreaks for fixed p_cure %2.2f' %float(p_cure))
    plt.xlabel('Simulations')
    plt.ylabel('Density')
    plt.xlim(0,max(zz[0]))




def fix_p_infect(n):
    """
    This will cover the third answer out of the  
    total 4 in analysis part.
    p_infect is fixed at 0.5 and p_cure is varied from 0 to 0.4 
    
    :param n: number of times the end of world simulation has to run
    :param p_cure: probability to cure a city
    
    :return fig: A figure showing the average number 
                of outbreaks it took to end the world for every possible 
                combination of fixed p_cure and varying p_infect
    """
    p_cure_array = numpy.linspace(0.1,0.4,4) ## Create an array of probabilities for p_infect to loop over to see variation in output
    p_infect = 0.5
    store_data = [] ## Initializing an empty variable to store loop results
    avg_outbreaks = [] ## Variable to store the average outbreaks per scenario
    for p_cure in p_cure_array: ## Loop p_infect over the array we created
        n_iter = end_world_many_times(n, p_infect, p_cure) ## Number of outbreaks it took to end the world
        avg_outbreaks.append(int(numpy.mean(n_iter))) ## Append average number of outbreaks into empty list
        store_data.append(n_iter) ## Append whole list into empty list 
    
		##  Here I use two different plotting strategies. One for when p_cure = 0 
		##  and other for when it is anything other than 0. 
		##  This is because, anytime p_cure and p_infect get close to each other 
		##  like p_infect = 0.1 and p_cure = 0.05, they take a huge number of 
		##  simulations to end the world as compared to other scenarios. 
		##  This makes them visually unreadable on a normal scale so I used 
		##  logarithmic scale to display them.
    
    import seaborn as sns
    import pandas as pd
    import matplotlib.pyplot as plt
    import numpy as np
    
    plt.hlines(y=p_cure_array, xmin=0, xmax=avg_outbreaks, color='skyblue')
    plt.xscale('log') ## Logarithmic y scale
    plt.plot(avg_outbreaks, p_cure_array, "o")
    plt.ylabel('p_cure')
    plt.xlabel('Average Number of outbreaks on Logarithmic Scale')
    for i,v in enumerate(avg_outbreaks): ## Annotating the total of each bar on top of the bar for better interpretation of results
        plt.text(int(avg_outbreaks[3] + 0.8*avg_outbreaks[3]),(i/10)+0.1,str(avg_outbreaks[i]), color='black', fontweight='bold')
    plt.title('Average number of outbreaks to take over the world. \n Fixed p_infect = %2.2f' %float(p_infect)) ## Plot title

def plot_end_world_many_times(n, p_infect, p_cure):
    outbreak_list = [] ## Create empty list to save loop results
    for i in range(0,n):
         outbreak_list.append(num_outbreaks_to_end_world(p_infect, p_cure))    
    sns.distplot(outbreak_list, hist=True, kde=True, 
             bins=int(max(outbreak_list)/5), color = '#7A67EE', 
             hist_kws={'edgecolor':'black'},
             kde_kws={'linewidth': 2})
    plt.title('Histogram and Density Plot')
    plt.xlabel('Number of Simulations')
    plt.ylabel('Density')
        

        
        
        