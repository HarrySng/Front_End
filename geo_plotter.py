from os import walk
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import re


def load_station_info(directory='./data/'):
    """
    Loads information about each weather station and stores it in a nested dictionary.
    :param directory: Directory (folder) containing the station information file.
    :return: A nested dictionary STATION ID -> dict of STATION INFO
    """
    temp_station_file = open(directory + 'Temperature_Stations.csv', 'r')
    temp_station_lines = temp_station_file.readlines()[4:]
    temp_station_dict = dict()
    for line in temp_station_lines:
        line = re.sub(r'[^a-zA-Z0-9.,-]+', '', line)
        line = line.strip().split(',')
        prov = line[0]
        station_name = line[1]
        station_id = line[2]
        begin_year = int(line[3])
        begin_month = int(line[4])
        end_year = int(line[5])
        end_month = int(line[6])
        lat = float(line[7])
        lon = float(line[8])
        elev = int(line[9])
        joined = line[10]

        temp_station_dict[station_id] = {'prov': prov, 'station_name': station_name, 'station_id': station_id,
                                         'begin_year': begin_year, 'begin_month': begin_month, 'end_year': end_year,
                                         'end_month': end_month,
                                         'lat': lat, 'lon': lon, 'elev': elev, 'joined': joined}

    return temp_station_dict


def load_temperature_data(directory='./data/'):
    """
    Loads temperature data from all files into a nested dict with station_id as top level keys.
    Data for each station is then stored as a dict: YEAR -> list of monthly mean temperatures.
    NOTE: Missing data is not handled gracefully - it is simply ignored.
    :param directory: Directory containing the temperature data files.
    :return: A nested dictionary STATION ID -> YEAR -> LIST OF TEMPERATURES
    """
    all_stations_temp_dict = dict()
    for _, _, files in walk(directory):
        for file_name in files:
            if file_name.startswith('mm'):
                station_temp_dict = dict()
                file = open(directory + file_name, 'r')
                station_id = file.readline().strip().split(',')[0]
                file.seek(0)
                file_lines = file.readlines()[4:]
                for line in file_lines:
                    line = re.sub(r'[^a-zA-Z0-9.,-]+', '', line)
                    line = line.strip().split(',')
                    year = int(line[0])
                    monthly_temperatures = []
                    for i in range(1, 24, 2):
                        value = float(line[i])
                        if value > -100:
                            monthly_temperatures.append(value)
                    station_temp_dict[year] = monthly_temperatures
                all_stations_temp_dict[station_id] = station_temp_dict
    return all_stations_temp_dict


def draw_map(plot_title, data_dict):
    """
    Draws a map of North America with temperature station names and values. Positive values are drawn next to red dots
    and negative values next to blue dots. The location of values are determined by the latitude and longitude. A
    dictionary (data_dict) is used to provide a map from station_name names to a tuple containing the (latitude, longitude, value)
    used for drawing.
    :param plot_title: Title for the plot.
    :param data_dict: A dictionary STATION NAME -> tuple(LATITUDE, LONGITUDE, VALUE)
    """
    fig = plt.figure(figsize=(9, 9))
    map1 = Basemap(projection='lcc', resolution=None, width=8E6, height=8E6, lat_0=53, lon_0=-97, )
    map1.etopo(scale=0.5, alpha=0.5)

    for station_name_name in data_dict:
        data = data_dict[station_name_name]
        print(station_name_name, data)
        x, y = map1(data[1], data[0])
        value = data[2]
        color = 'black'
        if value < 0:
            color = 'blue'
        elif value > 0:
            color = 'red'
        plt.plot(x, y, 'ok', markersize=2, color=color)
        plt.text(x, y, '{}\n {:.2f}℃'.format(station_name_name, value), fontsize=8)
    plt.title(plot_title)
    plt.show()


def make_station_name_dict(station_names, station_info_dict):
    """
    Makes a dictionary mapping station names to station ids.
    :param station_names: A list of station names. Station names must be in data file.
    :param station_info_dict: A dictionary STATION ID -> dict of STATION INFO
    :return: A dictionary STATION NAME -> STATION ID.
    """
    station_names_dict = dict()
    for name in station_names:
        for station_id in station_info_dict:
            station_details = station_info_dict[station_id]
            station_name = station_details['station_name']
            if station_name.lower() == name.lower():
                station_id = station_details['station_id']
                station_names_dict[name] = station_id
    return station_names_dict


"""
Your code starts here! Implement each function, one at a time, testing them along the way. There are lots of
parameters in this assignment - so make sure you're using them correctly. The first function, for example,
can be tested as follows:

station_names = ['London']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
temperatures = get_temperatures_for_year('London', 1989, station_name_dict, temperature_data_dict)

Test each function along the way using a similar strategy.

"""

def get_temperatures_for_year(station_name, year, station_name_dict, temperature_data_dict):
    """
    Given a station name and a year, the function uses the inter-connected dictionaries 
    to fetch temperature values of that particular year and station.
    
    :param station_name: The station name as a string.
    :param year: A year as an integer.
    :param station_name_dict: Dictionary mapping STATION NAME -> STATION ID
    :param temperature_data_dict: Dictionary mapping STATION NAME -> YEAR -> LIST OF TEMPERATURES
    
    :return tmp_list: A list of temperatures.
    """
    tmp_list = temperature_data_dict[station_name_dict[station_name]][year] # Extract the nested data based of that station and year
    return tmp_list

# Check funtion 1 using this comment block
'''
station_names = ['London']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
temperatures = get_temperatures_for_year('London', 1980, station_name_dict, temperature_data_dict)
'''

def get_station_coordinates(station_name, station_name_dict, station_info_dict):
    """
    Given a station_name, the function returns the coordinates of the station as a tuple

    :param station_name: The station name as a string.
    :param station_name_dict: Dictionary mapping STATION NAME -> STATION ID
    :param station_info_dict: Dictionary mapping STATION ID -> dict of STATION INFO
    
    :return coords: A tuple (longitude, latitude)
    """
    # returning tuple of coordinates using the nested directory links
    coords = (station_info_dict[station_name_dict[station_name]]['lat'],station_info_dict[station_name_dict[station_name]]['lon'])
    return coords

# Check funtion 2 using this comment block
'''
station_names = ['London']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
coords = get_station_coordinates('London', station_name_dict, station_info_dict)
'''

def compute_average_temp(temperatures):
    """
    Compute the average of a list of temperatures.
    :param temperatures: A list of temperature values.
    :return avg_tmp: Their average.
    """
    avg_tmp = round(np.mean(temperatures),2) # using numpy to find average
    return avg_tmp #return average temperature

# Check function 3 
'''
compute_average_temp(temperatures)
'''

def compute_average_change(temperatures):
    """
    Computes the average change over a list of temperatures
    
    :param temperatures: A list of temperature values.
    :return avg_change: The average change of these values.
    """
    # Using enumerate to do it in one line
    # Sum up all consecutive differences of values in temperature list
    # Then divide them with n-1 (as total changes for n elements is n-1)
    avg_change = round(sum([c - temperatures[i - 1] for i, c in enumerate(temperatures)][1:])/(len(temperatures)-1),2)
    return avg_change

# Check function 4 
'''
compute_average_change(temperatures)
'''

def make_average_change_dict(station_names, station_name_dict, temperature_data_dict, start_year, end_year):
    """
    Function iterates over each station in stations list, then each year from start year
    to end year and calculates average change in the period.
    The total average change is then appended to a dictionary with the station name as the key.

    :param station_names: A list of station names as strings.
    :param station_name_dict: Dictionary mapping STATION NAME -> STATION ID
    :param temperature_data_dict: Dictionary mapping STATION NAME -> YEAR -> LIST OF TEMPERATURES
    :param start_year: Start year, as integer, inclusive, for years in analysis.
    :param end_year: End year, as integer, exclusive, for years in analysis.
    
    :return avg_change_dict: Dictionary mapping STATION NAME -> AVERAGE TEMPERATURE CHANGE BETWEEN START_YEAR AND END_YEAR (float)
    """
    avg_change_dict = {} # Create dictionary
    for station in station_names: # Iterate over stations
        avg_temp_list = [] # Create a list to hold values of all years
        for year in np.arange(start_year,end_year,1): # Iterate over years from start to end (end is exclusive)
            temperatures = (get_temperatures_for_year(station, year, station_name_dict, temperature_data_dict)) # append temperature of lists in parent list
            avg_temp_list.append(compute_average_temp(temperatures)) # Finding mean using the average function
        avg_period_change = compute_average_change(avg_temp_list) # Calculate changes over all years in the period now 
        avg_change_dict[station] = avg_period_change # Insert the correct key (station name) and average change value into the dictionary
    return(avg_change_dict) # Return dictionary

# Check funtion 5 using this comment block
'''
station_names = ['London']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
avg_change_dict = make_average_change_dict(station_names, station_name_dict, temperature_data_dict, 1990, 2000)
'''

def make_average_change_dict_for_map(station_names, station_name_dict, station_info_dict, temperature_data_dict, start_year, end_year):
    """
    The function creates a dictionary mapping STATION NAMES to tuples(LATITUDE, LONGITUDE, AVERAGE TEMP CHANGE) over the range from
    start_year (inclusive) to end_year (exclusive).

    :param station_names: A list of station names as strings.
    :param station_name_dict: Dictionary mapping STATION NAME -> STATION ID
    :param station_info_dict: Dictionary mapping STATION ID -> dict of STATION INFO
    :param temperature_data_dict: Dictionary mapping STATION NAME -> YEAR -> LIST OF TEMPERATURES
    :param start_year: Start year, as integer, inclusive, for years in analysis.
    :param end_year: End year, as integer, exclusive, for years in analysis.
    
    :return avg_change_dict_map: A dictionary STATION NAME -> (LATITUDE, LONGITUDE, AVERAGE TEMP CHANGE)
    """
    avg_change_dict_map = {} # Create a dictionary
    # Call previous function to generate average change dictionary
    avg_change_dict = make_average_change_dict(station_names, station_name_dict, temperature_data_dict, start_year, end_year)
    for station in station_names: #I Iterate over station names
        coords = get_station_coordinates(station, station_name_dict, station_info_dict) # Get coordinates
        avg_change_dict_map[station] = (coords[0],coords[1],avg_change_dict[station]) # Insert a tuple of coordinates and average change into dictionary with station name as key
    return(avg_change_dict_map) # Return dictionary
    
# Check funtion 6 using this comment block
'''
station_names = ['Vancouver', 'Whitehorse', 'Yellowknife', 'Iqaluit', 'Calgary','Regina', 'Winnipeg', 'London', 'Quebec', 'Halifax', 'Gander']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
avg_change_dict_map = make_average_change_dict_for_map(station_names, station_name_dict, station_info_dict, temperature_data_dict, 1970, 1980)
'''

def draw_avg_change_map(station_names, station_name_dict, station_info_dict, temperature_data_dict, start_year, end_year):
    """
    Function takes station names, dictionaries and a range of years to create 
    a plot of average change at each station over those years.
    
    :param station_names: A list of station names as strings.
    :param station_name_dict: Dictionary mapping STATION NAME -> STATION ID
    :param station_info_dict: Dictionary mapping STATION ID -> dict of STATION INFO
    :param temperature_data_dict: Dictionary mapping STATION NAME -> YEAR -> LIST OF TEMPERATURES
    :param start_year: Start year, as integer, inclusive, for years in analysis.
    :param end_year: end_year: End year, as integer, exclusive, for years in analysis.
    :return: No return statement.
    """
    # Create dictionary from previous function
    avg_change_dict_map = make_average_change_dict_for_map(station_names, station_name_dict, station_info_dict, temperature_data_dict, start_year, end_year)
    plot_title = 'Annual Changes in Temperature over Canada from {} to {}'.format(start_year, end_year-1) # Create plot title (end_year - 1 as it is exclusive)
    draw_map(plot_title, avg_change_dict_map) # Call plotting function
    
# Check funtion 7 using this comment block
'''
station_names = ['Vancouver', 'Whitehorse', 'Yellowknife', 'Iqaluit', 'Calgary','Regina', 'Winnipeg', 'London', 'Quebec', 'Halifax', 'Gander']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
draw_avg_change_map(station_names, station_name_dict, station_info_dict, temperature_data_dict, 1970, 1980)
'''    
    

def draw_maps_by_range(station_names, station_name_dict, station_info_dict, temperature_data_dict, start_year, years_per_map, n):
    """
    Given the various data structure parameters, a start_year (inclusive, integer), years_per_map (integer), and n (integer),
    draw n maps, each showing the average change in temperature over years_per_map. For example, calling
    draw_maps_by_range(station_names, station_name_dict, station_data, temperature_data, 1950, 10, 2) will draw two maps,
    one with data from 1950 to 1959, and the other from 1960 to 1969.

    HINT: You can use a loop here to draw the maps!

    :param station_names:
    :param station_name_dict:
    :param station_data:
    :param temperature_data:
    :param start_year:
    :param years_per_map:
    :param num_maps:
    :return: No return statement.
    """
    i = 0 # Start a counter
    while (i < n): # Condition to loop over
        end_year = start_year + years_per_map # Add years per map to start year to get end year
        # Call plotting function
        draw_avg_change_map(station_names, station_name_dict, station_info_dict, temperature_data_dict, start_year, end_year)
        start_year = end_year # Put start year as the end year now for next loop
        i = i + 1 # Increase counter

    
# Check funtion 8 using this comment block
'''
station_names = ['Vancouver', 'Whitehorse', 'Yellowknife', 'Iqaluit', 'Calgary','Regina', 'Winnipeg', 'London', 'Quebec', 'Halifax', 'Gander']
station_info_dict = load_station_info()
station_name_dict = make_station_name_dict(station_names, station_info_dict)
temperature_data_dict = load_temperature_data()
draw_maps_by_range(station_names, station_name_dict, station_info_dict, temperature_data_dict, 1950, 10, 2)
'''    

# FINAL TEST RUN
'''
station_data = load_station_info()
temperature_data = load_temperature_data()
station_names = ['Vancouver', 'Whitehorse', 'Yellowknife', 'Iqaluit', 'Calgary','Regina', 'Winnipeg', 'London', 'Quebec', 'Halifax', 'Gander']
station_name_dict = make_station_name_dict(station_names, station_data)
draw_maps_by_range(station_names, station_name_dict, station_data, temperature_data, 1950, 10, 4)
'''