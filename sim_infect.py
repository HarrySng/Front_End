import os
# os.chdir('C:\\Users\\hsing247\\Desktop\\CS2120\\A2')
import numpy

#### This stuff you just have to use, you're not expected to know how it works.
#### You just need to read the plain English function headers.
#### If you want to learn more, by all means follow along (and ask questions if
#### you're curious). But you certainly don't have to.

def make_city(name,neighbours):
	"""
	Create a city (implemented as a list).
	
	:param name: String containing the city name
	:param neighbours: The city's row from an adjacency matrix.
	
	:return: [name, Infection status, List of neighbours]
	"""
	
	return [name, False, list(numpy.where(neighbours==1)[0])]
	

def make_connections(n,density=0.35):
	"""
	This function will return a random adjacency matrix of size
	n x n. You read the matrix like this:
	
	if matrix[2,7] = 1, then cities '2' and '7' are connected.
	if matrix[2,7] = 0, then the cities are _not_ connected.
	
	:param n: number of cities
	:param density: controls the ratio of 1s to 0s in the matrix
	
	:returns: an n x n adjacency matrix
	"""
	
	import networkx
	
	# Generate a random adjacency matrix and use it to build a networkx graph
	a=numpy.int32(numpy.triu((numpy.random.random_sample(size=(n,n))<density)))
	G=networkx.from_numpy_matrix(a)
	
	# If the network is 'not connected' (i.e., there are isolated nodes)
	# generate a new one. Keep doing this until we get a connected one.
	# Yes, there are more elegant ways to do this, but I'm demonstrating
	# while loops!
	while not networkx.is_connected(G):
		a=numpy.int32(numpy.triu((numpy.random.random_sample(size=(n,n))<density)))
		G=networkx.from_numpy_matrix(a)
	
	# Cities should be connected to themselves.
	numpy.fill_diagonal(a,1)
	
	return a + numpy.triu(a,1).T

def set_up_cities(names=['City 0', 'City 1', 'City 2', 'City 3', 'City 4', 'City 5', 'City 6', 'City 7', 'City 8', 'City 9', 'City 10', 'City 11', 'City 12', 'City 13', 'City 14', 'City 15']):
	"""
	Set up a collection of cities (world) for our simulator.
	Each city is a 3 element list, and our world will be a list of cities.
	
	:param names: A list with the names of the cities in the world.
	
	:return: a list of cities
	"""
	
	# Make an adjacency matrix describing how all the cities are connected.
	con = make_connections(len(names))
	
	# Add each city to the list
	city_list = []
	for n in enumerate(names):
		city_list += [ make_city(n[1],con[n[0]]) ]
	
	return city_list

def draw_world(world):
	"""
	Given a list of cities, produces a nice graph visualization. Infected
	cities are drawn as red nodes, clean cities as blue. Edges are drawn
	between neighbouring cities.
	
	:param world: a list of cities
	"""
	
	import networkx
	import matplotlib.pyplot as plt
	
	G = networkx.Graph()
	
	bluelist=[]
	redlist=[]
	
	plt.clf()
	
	# For each city, add a node to the graph and figure out if
	# the node should be red (infected) or blue (not infected)
	for city in enumerate(world):
		if city[1][1] == False:
			G.add_node(city[0])
			bluelist.append(city[0])
		else:
			G.add_node(city[0],node_color='r')
			redlist.append(city[0])
			
		for neighbour in city[1][2]:
			G.add_edge(city[0],neighbour)
	
	# Lay out the nodes of the graph
	position = networkx.circular_layout(G)
	
	# Draw the nodes
	networkx.draw_networkx_nodes(G,position,nodelist=bluelist, node_color="b")
	networkx.draw_networkx_nodes(G,position,nodelist=redlist, node_color="r")

	# Draw the edges and labels
	networkx.draw_networkx_edges(G,position)
	networkx.draw_networkx_labels(G,position)

	# Force Python to display the updated graph
	plt.show()
	plt.draw()
	
def print_world(world):
    """
    In case the graphics don't work for you, this function will print
    out the current state of the world as text.

    :param world: a list of cities
    """

    print('{:15}{:15}'.format('City', 'Infected?'))
    print('------------------------')
    for city in world:
        print('{:15}{}'.format(city[0], city[1]))



#### That's the end of the stuff provided for you.
#### Put *your* code after this comment.
  
def spread_infection(middle_earth, region):
    """
    The function infects a single city as specified by the input. 
    Basically flipping the Boolean FALSE to TRUE for that index.
    
    :param middle_earth: a list of cities
    :param region: index of city
    """
    middle_earth[region][1] = True

def spread_cure(middle_earth, region):
    """
    The function takes the list of regions as an input and removes 
    infection from that area. 
    Basically flipping the Boolean TRUE to FALSE for that city index. 
    
    The IF statement handles the fact that ground zero is never cured. 
    
    :param middle_earth: a list of cities
    :param region: index of city
    """
    if region == 0:
        middle_earth[region][1] = True ## Making sure that ground zero is never cured
    else:
        middle_earth[region][1] = False ## Region is cured

def outbreak_sim(middle_earth, p_infect, p_cure):
    """
    This function simulates a single step of outbreak of infection. 
    I am not putting probability (0,1) range constraints here. 
    I will put it in the final function which runs all of these simulations. 
    It will act recursively and stop the simulation if user enters an 
    unreasonable probability range. 
    I have included a WHILE statement to handle the case when the  
    neighbor selected at random is the same as the original region itself. 
    
    :param middle_earth: a list of cities
    :param p_infect: probability of infecting a city
    :param p_cure: probability of curing a city
    """
    import random ## Using random.choice instead of numpy.random.int
    for region in range(0,len(middle_earth)):
        if middle_earth[region][1] == True and numpy.random.rand() < p_infect: ## If region is infected and the random number is less that probability
            target_region = random.choice(middle_earth[region][2]) ## Select random region from neighbor list
            while target_region == region: ## If random region selected is the original region itself
                target_region = random.choice(middle_earth[region][2]) ## Choose random region again in this case
            else:
                spread_infection(middle_earth, target_region) ## The region will be infected
            
        if middle_earth[region][1] == True and numpy.random.rand() < p_cure: ## If region is infected and the random number is less that probability
            spread_cure(middle_earth, region) ## The region will be cured (given that it is not ground zero)
    
def is_end_of_world(middle_earth):
    """
    Function extracts the boolean value out of our regions list. 
    Checks whether all Booleans are True or False and reports 
    whether the world has ended based on that. 
    If all values are True, the world has ended, otherwise not.
	Returning 1,0 for simplicity, and avoiding confusion with 
	infected status of True/False.
    
    :param middle_earth: a list of cities
    
    :return 0: for world not ended
    :return 1: for world ended
    """
    status = [middle_earth[region][1] for region in range(0,len(middle_earth))]  ## Extracting the status of each city
    if False in status: ## Check if any value of status is false, it means world has not ended yet
        return 0    ## World has not ended
    else:          	
        return 1    ## World has ended

def num_outbreaks_to_end_world(p_infect, p_cure):
    """
    Function finds the number of outbreaks it takes for the infection 
    to take over the world.  
    Steps in this function: 
        1. Make sure you start from scratch - Create a new world 
        2. Infect ground zero 
        3. Run the simulation till all regions are infected 
        4. Return the number of simulations it took to infect all regions 
    
    Here notice the num_outbreaks < 1000,000 in the WHILE statement. 
    This has been done because when during our final simulation run 
    we fix p_cure and vary p_infect, the simulation can take a very 
    very long time to run when the two probabilities are close to each 
    other (example p_cure = 0.55 and p_cure = 0.5).
    Also, as our p_cure gets larger than p_infect, the world would effectively 
    never end so we would have to stop the simulation at some point. 
    So, to handle this, I have added this step that if the number of simulations 
    goes above 1 million, just return 1 million. 
    
    :param p_infect: probability of infecting a city
    :param p_cure: probability of curing a city
    
    :return num_outbreaks: Single value for number of outbreaks (simulation) 
						 it took to end the world.
    """
    
    ## Creating world from scratch
    middle_earth = set_up_cities(names=['Mordor', 'Bree', 'Rivendell', 'Mithlond', 'Isengard', 'Mount Gundabad', 'Dale', 'Rohan', 'Hobbiton', 'Erebor', 'The Iron Hills', 'Minas Tirith', 'Gondor', 'Minas Morgul', 'Morannon', 'Haradwaith'])
    spread_infection(middle_earth,0) ## Infect ground zero
    num_outbreaks = 0 ## Initializing the counter for end of world. This is the number of outbreaks (simulations).
    curr_status = is_end_of_world(middle_earth) ## Check if the world has ended or not
    while (curr_status == 0 and num_outbreaks < 1000000): ## While world has not ended and number of simualtions is below 1 million
        outbreak_sim(middle_earth,p_infect, p_cure) ## Simulate the outbreak again
        num_outbreaks = num_outbreaks + 1 ## Increment the outbreak counter
        curr_status = is_end_of_world(middle_earth) ## Change the current status of world     
    return num_outbreaks ## Return the final number of outbreaks
    

def end_world_many_times(n, p_infect, p_cure):
    """
    This function runs our single end of the world simulation 
    multiple times (n). In this step, I am applying a check 
    for the user entering a reasonable probability range. 
    
    :param p_infect: probability to infect a city
    :param p_cure: probability to cure a city
    
    :return outbreak_list: a list of n elements containing number of oubtbreaks it 
                            took each time to end the world. 
    """
    if (
        0 <= p_infect <= 1 ## Check for probability range between 0-1
        and
        0 <= p_cure <= 1 ## Check for probability range between 0-1
        ):
        outbreak_list = [] ## Create empty list to save loop results
        for i in range(0,n):
            outbreak_list.append(num_outbreaks_to_end_world(p_infect, p_cure)) ## Call previous function and append loop results in empty list
        return outbreak_list ## Return the final list
    else:
        print('The probability range should be between 0 and 1. Please try again.') ## Print if out of bound probability range
        
################################ SIMULATION SETUP COMPLETE ################################

## Answer 1
num_outbreaks_to_end_world(0.9, 0) 
num_outbreaks_to_end_world(0.7, 0) 
num_outbreaks_to_end_world(0.5, 0) 

## Answer 2
num_outbreaks_to_end_world(0.9, 0.05) 
num_outbreaks_to_end_world(0.7, 0.05) 
num_outbreaks_to_end_world(0.5, 0.05) 

## Answer 3
num_outbreaks_to_end_world(0.5, 0.1) 
num_outbreaks_to_end_world(0.5, 0.2) 
num_outbreaks_to_end_world(0.5, 0.3) 
num_outbreaks_to_end_world(0.5, 0.4)

## Answer 4
end_world_many_times(500, .9, .1)
end_world_many_times(500, .8, .2)
end_world_many_times(500, .7, .3)