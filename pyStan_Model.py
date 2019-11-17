import pystan
import pandas as pd
import os
import glob
import pystan
import pickle
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from mpl_toolkits.basemap import Basemap
import re


stan_code = """
data { 
    int<lower=0> n;
    real Level[n];
    real tFlow[n];
}
transformed data {}
parameters {
    real c;
    real c1;
    real sigma;
}
transformed parameters {
    real mu[n];
    for (i in 1:n) {
        mu[i] <- c1*Level[i] + c;
        }
}
model {
    sigma ~ cauchy(0, 10);
    tFlow ~ normal(mu, sigma);
}
generated quantities {}
"""

# CHANGE DATA PATHS to run the model.
# NOTE: Meta data file (HydatStations.csv) should NOT BE in the same folder as actual data files.
#meta_data = pd.read_csv('HydatStations.csv')
#os.chdir('./clnData')
#data_files = [i for i in glob.glob('*.{}'.format('csv'))]

def multi_bayes(data_files):
    '''
    Function takes a list of file names as input, reads in the csv data and then trains the stan model on the data.
    The output is a dictionary with station name as key and the coordinates and the final relative uncertainty 
    measure of each station,
    
    param data_files: list of csv file names corresponding to HYDAT stations
    
    return unc_dict: A dictionary object containing station coordinates and relative uncertainty of rating curve
    '''
    unc_dict = {}
    for file in data_files:
        df = pd.read_csv(file)
        model_input = dict(n=len(df[0:]), tFlow = df['tFlow'],  Level = df['Level'])
        
        m = pystan.stan(model_code = stan_code, data = model_input, iter=2000, chains=1)
        
        intercept_ = (np.quantile(m['c'],0.025), np.quantile(m['c'],0.5), np.quantile(m['c'],0.975))
        coeff_ = (np.quantile(m['c1'],0.025), np.quantile(m['c1'],0.5), np.quantile(m['c1'],0.975))
        sig_ = (np.quantile(m['sigma'],0.025), np.quantile(m['sigma'],0.5), np.quantile(m['sigma'],0.975))
        
        pred_Flow = [(intercept_[0] + df['Level']*coeff_[0])**2,
                     (intercept_[1] + df['Level']*coeff_[1])**2,
                     (intercept_[2] + df['Level']*coeff_[2])**2]
        
        rel_uncrt = round(((np.mean(pred_Flow[2]) - np.mean(pred_Flow[0]))/np.mean(pred_Flow[1]))*100,2)
        
        unc_dict[df['ID'][0]] = (float(meta_data.loc[meta_data['Station'] == df['ID'][0]][' Latitude']), float(meta_data.loc[meta_data['Station'] == df['ID'][0]][' Longitude']), rel_uncrt)
        
    return(unc_dict)

'''
Uncomment to run bayesian models.
WARNING: It can take upto 15-20 minutes for compilation.
You need to have C++ compiler installed on your system.

model_list = multi_bayes(data_files)
'''

def draw_map(plot_title, data_dict):
    """
    Slightly changed version of Assignment-3 mapping code.
    Draws a map of Southern Ontario with temperature station names. The location of values are determined by the latitude 
    and longitude. A dictionary (data_dict) is used to provide a map from station_name names to a tuple containing the (latitude, longitude, value)
    used for drawing.
    
    :param plot_title: Title for the plot.
    :param data_dict: A dictionary Station ID -> tuple(Latitude, Longitude, Uncertainty Value)
    """
    fig = plt.figure(figsize=(12, 12))
    map1 = Basemap(projection='cyl', resolution='c', width=8E6, height=8E6, llcrnrlat=42, urcrnrlat=45.,llcrnrlon=-84.,urcrnrlon=-74 )
    map1.arcgisimage(service='ESRI_Imagery_World_2D', xpixels = 2000, verbose= True)

    for station_name_name in data_dict:
        data = data_dict[station_name_name]
        print(station_name_name, data)
        x, y = map1(data[1], data[0])
        value = data[2]
        color = 'white'
        plt.plot(x, y, 'ok', markersize=3, color='red')
        plt.text(x, y, '{}'.format(value), fontsize=8, color = color)
    plt.title(plot_title)
    plt.show()
    
'''
Uncomment to plot map. Needs input from multi_bayes() function.
draw_map('Relative Uncertainty Map', model_list)
'''


def lone_model(x):
    '''
    Function takes input from user to either run the model with minimum uncertainty or
    maximum uncertainty.
    
    param x: A string indicating 'min' or 'max' uncertainty
    
    return m: Stan model
    '''
    if x == 'min':
        sid = min(model_list, key=model_list.get) # Extract Station ID with minimum uncertainty
    elif x == 'max':
        sid = max(model_list, key=model_list.get) # Extract Station ID with maximum uncertainty
    
    file = '{}_Data.{}'.format(sid,'csv')
    df = pd.read_csv(file)
    
    model_input = dict(n=len(df[0:]), tFlow = df['tFlow'],  Level = df['Level'])   
    m = pystan.stan(model_code = stan_code, data = model_input, iter=2000, chains=1)
    
    return(m)

''' 
Uncomment to run
   
best_model = lone_model('min')
worst_model = lone_model('max')
'''

def plot_pars(par, par_name):

    par1 = best_model[par]
    par2 = worst_model[par]

    par1_mean = np.mean(par1)
    par2_mean = np.mean(par2)
    
    par1_median = np.median(par1)
    par2_median = np.median(par2)
    
    lower_par1, upper_par1 = np.quantile(par1, 0.025), np.quantile(par1, 0.975)
    lower_par2, upper_par2 = np.quantile(par2, 0.025), np.quantile(par2, 0.975)
    
    fig = plt.figure(figsize=(10, 10))
    plt.subplot(4,2,1)
    plt.plot(par1, color = 'lightcoral')
    plt.xlabel('Samples')
    plt.ylabel(par_name)
    plt.axhline(par1_mean, color='blue', lw=2, linestyle='--')
    plt.axhline(par1_median, color='c', lw=2, linestyle='--')
    plt.axhline(lower_par1, linestyle=':', color='k', alpha=0.2)
    plt.axhline(upper_par1, linestyle=':', color='k', alpha=0.2)
    plt.title('Trace Plot and Density for best model {}'.format(par_name))
    
    plt.subplot(4,2,2)
    plt.hist(par1, 30, density=True, color = 'lightcoral'); sns.kdeplot(par1, shade=True)
    plt.xlabel(par_name)
    plt.ylabel('Density')
    plt.axvline(par1_mean, color='blue', lw=2, linestyle='--',label='mean')
    plt.axvline(par1_median, color='c', lw=2, linestyle='--',label='median')
    plt.axvline(lower_par1, linestyle=':', color='k', alpha=0.2, label=r'95\% CI')
    plt.axvline(upper_par1, linestyle=':', color='k', alpha=0.2)
    
    plt.subplot(4,2,3)
    plt.plot(par2, color = 'lightcoral')
    plt.xlabel('Samples')
    plt.ylabel(par_name)
    plt.axhline(par2_mean, color='blue', lw=2, linestyle='--')
    plt.axhline(par2_median, color='c', lw=2, linestyle='--')
    plt.axhline(lower_par2, linestyle=':', color='k', alpha=0.2)
    plt.axhline(upper_par2, linestyle=':', color='k', alpha=0.2)
    
    plt.subplot(4,2,4)
    plt.hist(par2, 30, density=True, color = 'lightcoral'); sns.kdeplot(par2, shade=True)
    plt.xlabel(par_name)
    plt.ylabel('Density')
    plt.axvline(par2_mean, color='blue', lw=2, linestyle='--',label='mean')
    plt.axvline(par2_median, color='c', lw=2, linestyle='--',label='median')
    plt.axvline(lower_par2, linestyle=':', color='k', alpha=0.2, label=r'95\% CI')
    plt.axvline(upper_par2, linestyle=':', color='k', alpha=0.2)
    
'''
Uncomment to run

plot_pars('c','Intercept')
plot_pars('c1','Reg. Coefficient')
plot_pars('sigma','Std. Deviation')
'''

def plot_flow(x):
    '''
    Function plots observed vs predicted flows for a model.
    
    param x: A string indicating 'min' or 'max' uncertainty
    
    '''
    if x == 'min':
        sid = min(model_list, key=model_list.get) # Extract Station ID with minimum uncertainty
        m = best_model
    elif x == 'max':
        sid = max(model_list, key=model_list.get) # Extract Station ID with maximum uncertainty
        m = worst_model
    
    file = '{}_Data.{}'.format(sid,'csv')
    df = pd.read_csv(file)
    
    intercept_ = (np.quantile(m['c'],0.025), np.quantile(m['c'],0.5), np.quantile(m['c'],0.975))
    coeff_ = (np.quantile(m['c1'],0.025), np.quantile(m['c1'],0.5), np.quantile(m['c1'],0.975))
    sig_ = (np.quantile(m['sigma'],0.025), np.quantile(m['sigma'],0.5), np.quantile(m['sigma'],0.975))
        
    pred_Flow = [(intercept_[0] + df['Level']*coeff_[0])**2,
                (intercept_[1] + df['Level']*coeff_[1])**2,
                (intercept_[2] + df['Level']*coeff_[2])**2]
    
    fig = plt.figure(figsize=(10, 10))
    plt.scatter(df['Level'],df['Flow'], color = 'green', alpha=0.3, s = 100)
    plt.scatter(df['Level'],pred_Flow[0], color = 'lightcoral', s = 20)
    plt.scatter(df['Level'],pred_Flow[1], s = 20, color = 'blue')
    plt.scatter(df['Level'],pred_Flow[2], color = 'lightcoral', s = 20)
    plt.xlabel('Level')
    plt.ylabel('Discharge')
    plt.title('Observed vs Predicted Flow')
    plt.legend(['Observed Flow','Confidence Bound','Median Flow','Confidence Bound'])
    
'''
Uncomment to run

plot_flow('min')
plot_flow('max')
'''