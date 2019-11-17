###  Importing some modules for the script
import calendar as cl
import matplotlib.pyplot as plt
import os
import numpy as np
import pandas as pd
###  os.chdir('C:\\Users\\hsing247\\Desktop\\CS2120\\A1')  
###  Setting working directory where the csv file is present (Change for your system)

def load_asn1_data(filename='LondonTemperatures.csv'):
    """
    This function loads the file `LondonTemperatures.csv` and returns a LIST of
    of temperature recods... and each element of the list is ANOTHER LIST
    that contains 13 values: the year followed by a mean temperature for each month
    We'll talk about lists formally in class in a few lectures, but maybe
    you can start guessing how they work based on what you see here...
    """
    import re

    file = open(filename, 'r')
    records = []

    for r in file.readlines():
        r = re.sub(r'[^a-zA-Z0-9.,-]+', '', r)
        records.append(r.split(','))
        
    return records

tls = load_asn1_data() ###   Saving the returned list of function into a variable

def coldest_month(records):
    """
    Function to find which month was the coldest on record.

    :returns: A string indicating the month, year, and mean temperature of the coldest month on record.
    """

    # HINT: You should probably initialize some kind of variables here. Maybe to hold
    # the current coldest month (and year!) and temperature.
    # INSERT YOUR CODE HERE!
    parent_list = []
    ### Creating a list which will hold the appended results of for loop written below


    # This is an instruction to Python: Do the body (the indented code) following
    # `for` statement, for _every_ record in our list of temperature data.
    # This is a LOOP. It's already written for you... you just have to fill in the body
    
    for record in records:

        # Here we're extracting the information from each record and storing it
        # in variables. It's not great form to create variables that you don't use,
        # but since you'll probably use this as a template to solve other parts of the
        # assignment, I'm going to extract _everything_ into variables for you.
        
        ### I have removed the creation of individual variables. I will not need them
        
        ### Here I have replaced all code with a single line
        ### In the parent list created above, I am appending a tuple for every loop
        ### This tuple holds two values
        ### First value is the minimum temperature of each year
        ### Second value is the index of that minimum temperature which will give us the month value indirectly (1 = Jan, 2 = Feb ... so on)
        parent_list.append((float(min(record[1:len(record)])),record.index(min(record[1:len(record)]))))
    
        # Determine whether any of these mean monthly temperatures are colder than the coldest seen so far.
        # INSERT YOUR CODE HERE! Hint: You don't have to use a loop or any lists - but they could help!
    ### Now as our parent_list has both float/int items in the nested tuples, we can use a direct MIN command to find the minimum temp out of all records   
    ### Also getting the index, because that will give us the year value
    ans = (min(parent_list), parent_list.index(min(parent_list)))
    
    ### This ans varable gives us all the information we need
    ### Its value is ((-13.3,2), 1)
    ### -13.3 is the least temperature value of all
    ### Index 2 is the month = February
    ### Index 1 is the year index
    
    ### Here I am using the CALENDAR library to convert month number to month string
    month = cl.month_name[ans[0][1]]
    ### Now pull out the year from the original records based on our year index
    year = records[ans[1]][0]
    
    ### Now just to print our answer
    print('The ',month,' of ',year,' was the coldest month in the last ',int(records[len(records)-1][0]) - int(records[0][0]),' years with an average temperature of ',ans[0][0],' degrees Celsius.')
    ### Added some extra information to the answer like the number of years checked etc.

    # RETURN a string indicating the month, year, and coldest temperature. e.g. "January 2015 was the coldest month on
    # record with a mean temperature of -3 degrees."


coldest_month(tls)

### Basically repeting the same format as above for the warmest month
def warmest_month(records):
    """
    Function to find which month was the coldest on record. 

    :returns: A string indicating the month, year, and mean temperature of the coldest month on record.
    """

    # HINT: You should probably initialize some kind of variables here. Maybe to hold
    # the current coldest month (and year!) and temperature.

    # INSERT YOUR CODE HERE!
    parent_list = []
    ### Creating a list which will hold the appended results of for loop written below


    # This is an instruction to Python: Do the body (the indented code) following
    # `for` statement, for _every_ record in our list of temperature data.
    # This is a LOOP. It's already written for you... you just have to fill in the body
    
    for record in records:

        # Here we're extracting the information from each record and storing it
        # in variables. It's not great form to create variables that you don't use,
        # but since you'll probably use this as a template to solve other parts of the
        # assignment, I'm going to extract _everything_ into variables for you.
        
        ### I have removed the creation of individual variables. I will not need them
        
        ### Here I have replaced all code with a single line
        ### In the parent list created above, I am appending a tuple for every loop
        ### This tuple holds two values
        ### First value is the maximum temperature of each year
        ### Second value is the index of that maximum temperature which will give us the month value indirectly (1 = Jan, 2 = Feb ... so on)
        parent_list.append((float(max(record[1:len(record)])),record.index(max(record[1:len(record)]))))
    
        # Determine whether any of these mean monthly temperatures are colder than the coldest seen so far.
        # INSERT YOUR CODE HERE! Hint: You don't have to use a loop or any lists - but they could help!
    ### Now as our parent_list has both float/int items in the nested tuples, we can use a direct MAX command to find the minimum temp out of all records   
    ### Also getting the index, because that will give us the year value
    ans = (max(parent_list), parent_list.index(max(parent_list)))
    
    ### This ans varable gives us all the information we need
    ### Its value is ((24.7,7), 73)
    ### 24.7 is the least temperature value of all
    ### Index 7 is the month = July
    ### Index 73 is the year index
    
    ### Here I am using the CALENDAR library to convert month number to month string
    month = cl.month_name[ans[0][1]]
    ### Now pull out the year from the original records based on our year index
    year = records[ans[1]][0]
    
    ### Now just to print our answer
    print('The ',month,' of ',year,' was the warmest month in the last ',int(records[len(records)-1][0]) - int(records[0][0]),' years with an average temperature of ',ans[0][0],' degrees Celsius.')
    ### Added some extra information to the answer like the number of years checked etc.
    # RETURN a string indicating the month, year, and coldest temperature. e.g. "January 2015 was the coldest month on
    # record with a mean temperature of -3 degrees."


warmest_month(tls)


def print_mean_annual_temperature(year, records):
    """
    Given a year, print the average temperature over that year. If there are no
    records for that year, the program should not crash - instead it should print
    a message saying the data is unavailable.
    :param year: Year for which mean temperature should be printed.
    :param records: A list of lists containing temperature data.
    """

    # INSERT YOUR CODE HERE!
    # Initialize variables
	### Not initializing any variables here, will do it inside the loop

    # A loop to get you started.
    # HINT: Use other parts of this code to help solve this problem!
    # Note: Using a loop here might not be the most efficient way to solve this problem.
    #       We'll talk about why not later in the course. For now, it'll do the trick.
    for record in records:
        if year == int(record[0]): ### If year entered matches the year available
            p_data = record ### Pull out the data of that year into a variable
     
        # INSERT YOUR CODE HERE!
        # Find the record that matches 'year' and print a formatted string with the mean annual temperature.
    if 'p_data' not in locals(): ### Check if p_data was created or not (if the year didnt match, its not created)
        print('The data for this year is unavailable.') ### print message if not created
    else:
        print('The average temperature of ', int(p_data[0]), ' is ', round(np.mean([float(x) for x in p_data[1:len(p_data)]]),2), ' degrees Celsius.')
    ### I used numpy here to calculate mean rather than typing out the full formula   

# Test your function.
print_mean_annual_temperature(2012, tls) ### pass case
print_mean_annual_temperature(9999, tls) ### fail case


### BONUS - No marks, just for the curious/ambitious. Write a function that takes 'records' and produces a plot of the mean temperature
### over all years in the data. You should be able to do this using simple functions from matplotlib - just Google it!

### Going to do this using pandas

def all_temp_plot(records):
    big_frame = pd.DataFrame(records) ### Collapse the nested lists into one big dataframe
    big_frame = big_frame.apply(pd.to_numeric) ### Convert whole data frame to numeric
    mean_frame = pd.concat([big_frame.iloc[:,0], round(big_frame.iloc[:,1:].mean(axis=1),2)], axis=1) ### Create a new data frame with 2 columns, YEAR and MEAN TEMP
    mean_frame.columns = ['Year','Mean Temperature'] ### Naming the columns
    plt.figure() ### Creating base plot
    ### Plotting the data with relevant parameters
    mean_frame.plot(x = 'Year', y = 'Mean Temperature', 
                    kind = 'line', title = 'Average Annual Temperature Plot',
                    xticks = np.arange(int(min(big_frame.iloc[:,0])-10),int(max(big_frame.iloc[:,0])+10),20))

### Run the function to plot the figure
all_temp_plot(tls)

### I have written one more function just for practice, you can ignore it.
### Function asks user to input a year and then plots the temperature of that particular year

def temp_plot(records):
    big_frame = pd.DataFrame(records) ### Collapse the nested lists into one big dataframe
    big_frame = big_frame.apply(pd.to_numeric) ### Convert whole data frame to numeric
    year = int(input("Please enter a year to plot its temperature: "))
    if (year < min(big_frame.iloc[:,0]) & year > max(big_frame.iloc[:,0])): ### Check if year entered lies between our range of years available
        print('The data of this year is not available. Please enter a year between ',min(big_frame.iloc[:,0]),' and ',max(big_frame.iloc[:,0]))
    else:
        sel_data = big_frame.loc[big_frame[0] == year] ### Extract the selected year's row
        sel_data = sel_data.iloc[:,1:].T ### Transpose it
        sel_data.columns = ['Temperature'] ### Name the column
        plt.figure() ### Creating base plot
        sel_data.plot(y = 'Temperature', marker='o', linestyle='--', color='b') ### Plot the data
        
temp_plot(tls) ### Run the function

