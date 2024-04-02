######################################################################
## Plotting utilities developed by Paul Vautravers
## Migrated from era_5_cape_pmax_functions-main.ipynb
######################################################################

# Import libraries and set plotting parameters
import numpy as np
import scipy as sp
import xarray as xr
import matplotlib.pyplot as plt
import pandas as pd
import warnings, time

from scipy.optimize import curve_fit
from matplotlib.ticker import FuncFormatter

plt.rcParams.update({'font.size': 12})

warnings.filterwarnings(action='ignore')

# Files to access NetCDF data and store cape and precipitation into numpy arrays
def file_concatenator(numerical_list):
    #Takes a list of numbers corresponding to filenumbers/years 
    #and compiles the corresponding list of filenames
    file_names = []
    
    #base directory where the desired files are located
    basedir = '/groups/sylvia/JAS-MCS-rain/ERAI/'
    
    #iterates through numbers
    for value in numerical_list:
        #appending list of files
        file_names = np.append(file_names,(basedir + 'colloc_' + str(value) + '_NZ.nc'))
        
    return file_names


def nc_open_compile(files,variable_name,compile_type='append'):
    #opens netcdf files, in a list, and either stacks or appends the data
    #files = list containing file names
    #variable_name is a string of the desired variable
    
    #opens a file in 'files' and extracts data for a given variable
    for i,file in enumerate(files):
        if i == 0:
            variable = (xr.open_dataset(file))[variable_name]
        else:
            #kwarg assumes append, but vstack can also be used
            if compile_type == 'stack':
                variable = np.vstack((variable,(xr.open_dataset(file))[variable_name]))
            else:
                variable = np.append(variable,(xr.open_dataset(file))[variable_name])
    return variable


def negative_vals(y,x):
    #function to take negative values in some array y and couple with corresponding x values
    
    #taking array values less than 0, negative values
    indices = np.where(y<0)

    #creating a new array of just negative values from w
    y_n = y[indices]

    #taking cape values corresponding to negative w
    x_n = x[indices]

    #making the values positive for logarithms
    y_n = abs(y_n)
    
    return y_n,x_n

def positive_vals(y,x):
    #function to take negative values in some array y and couple with corresponding x values
    
    #taking array values less than 0, negative values
    indices = np.where(y>=0)

    #creating a new array of just negative values from w
    y_p = y[indices]

    #taking cape values corresponding to negative w
    x_p = x[indices]

    #making the values positive for logarithms
    y_p = abs(y_p)
    
    return y_p,x_p

def negative_to_nan(array):
    #simply converts not positive values to NaNs
    array = np.where(array<=0, np.NaN, array)
    return array

def positive_to_nan(array):
    #simply converts not negative values  to NaNs
    array = np.where(array>=0, np.NaN, array)
    return array

def nan_array(shape):
    an_array = np.empty(shape)
    an_array[:] = np.NaN
    return an_array


# Finding the mean and percentiles of the data
def maxk_arg(matrix,k):
    #returns indices of max k elements in a matrix
    if len(matrix.shape) > 1:
        matrix_new = matrix.flatten()
    else:
        matrix_new = matrix
    #remove any nans
    matrix_new = matrix_new[~np.isnan(matrix_new)]
    matrix_arg = np.argsort(matrix_new)
    return matrix_arg[-k:]


def bin_stat_function(n_bins,lower,upper,x_variable,y_variable,threshold=0,pc1=95,pc2=99.9,n_max=5):
    #Creates a range of bin values within which the data should lie, collects indices of x-variables
    #which fall in those bins and calls the corresponding y-variable values, calculates means
    #and percentiles. 
    
    #n_bins = number of bins
    #lower and upper = bounds of bins
    #threshold is a required number of values if statistics are to be calculated
    #pc1,2 are percentiles, assumed 95 and 99.9
    #n_max = number of maximum values to extract in each bin
    
    cc = np.linspace(lower,upper,n_bins)
    
    #nan filled arrays created
    x_bins = nan_array((n_bins,))
    y_bins = nan_array((n_bins,))
    
    y_bins_pc1 = nan_array((n_bins,))
    y_bins_pc2 = nan_array((n_bins,))
    
    x_max = nan_array((n_bins,n_max))
    y_max = nan_array((n_bins,n_max))
    
    x_bins_error = nan_array((n_bins,))
    y_bins_error = nan_array((n_bins,))
    
    #reduced bin values for the loop below
    cc_red = cc[:-1]
    for i, value in enumerate(cc_red):
        #indices of values within bins
        j = np.where((x_variable >= cc[i]) & (x_variable < cc[i+1]))
        
        x_vals = x_variable[j]
        y_vals = y_variable[j]

        #threshold inspected    
        if len(j[0]) > threshold:
            #mean of x values within bin
            x_bins[i] = np.nanmean(x_vals)
            x_bins_error[i] = np.nanstd(x_vals)   
            
            #mean and percentiles of associated y variable
            y_bins[i] = np.nanmean(y_vals)
            y_bins_error[i] = np.nanstd(y_vals)
    
            y_bins_pc1[i] = np.nanpercentile(y_vals,pc1)
            y_bins_pc2[i] = np.nanpercentile(y_vals,pc2)

        #if len(j[0]) >= n_max:
        #    j = maxk_arg(y_vals,n_max)
        #    # The same filter applied in the maxk_arg function must be applied here also.
        #    x_vals = x_vals[~np.isnan(x_vals)]
        #    y_vals = y_vals[~np.isnan(y_vals)]
        #    x_max[i] = x_vals[j]
        #    y_max[i] = y_vals[j]
    
    return x_bins,y_bins,y_bins_pc1,y_bins_pc2,x_bins_error,y_bins_error,x_max,y_max



def mean_pc_max_plot( x_bins, y_arrays, errors, labels, percentiles=[95,99] ):
    #plots x bin values against precip bin values
    
    #y_arrays has format: [y mean, y pc1, y pc2, y max]
    #errors has format: [x error,y error]
    #labels has format: [suptitle,[x_name,x_unit],[y_name,y_unit]],strings
    #percentiles has format: [percentile 1, percentile 2]
    fig, ax = plt.subplots(2,2, figsize =(10, 8))
    
    # commenting out any title for now
    #fig.suptitle(labels[0],fontsize =20)
   
    # set the fontsize large enough
    font_size = 15
    plt.rcParams.update({
	'font.size':font_size,
        'axes.labelsize':font_size+2,
        'xtick.labelsize':font_size,
        'ytick.labelsize':font_size,
        'legend.fontsize':font_size,
    })
 
    #list of labels to be iterated through
    title_terms = ['Mean','{}th Percentile'.format(percentiles[0]),
                   '{}th Percentile'.format(percentiles[1]),'Max']
                       
    ylab = [ r'Mean $\dot{P}$', r'95th percentile $\dot{P}$', r'99th percentile $\dot{P}$',\
             r'Max $\dot{P}$' ]
    let = [ '(a)', '(b)', '(c)', '(d)' ]
    #ax.flat allows iteration through the subplots
    for i, axis in enumerate(ax.flat): 
        if i == 0:
            axis.errorbar(x_bins[0].flatten(), (y_arrays[i]).flatten(),xerr=errors[0].flatten(),
                          yerr=errors[1].flatten(), color = 'blue',ls='none')
        elif i == 3:
            axis.scatter(x_bins[1].flatten(), (y_arrays[i]).flatten(),color = 'blue')
        else:
            #arrays flattened, precip arrays iterated through
            axis.scatter(x_bins[0].flatten(), (y_arrays[i]).flatten(), color = 'blue')
          
        #x variable unit and name formatted in
        if i == 1 or i == 3:
           axis.set(xlabel = labels[1][0] + " [${}$]".format(labels[1][1]))
        #axis.set(ylabel = labels[2][0] + " [${}$]".format(labels[2][1]))
        axis.set(ylabel = ylab[i])
        axis.text(0.05, 0.95, let[i], transform=axis.transAxes, fontsize=font_size, weight='bold')
        # no title for now
        #axis.set_title(title_terms[i] + " {} ".format(labels[2][0]))
        
        # axis upper and right lines removed
        axis.spines['top'].set_visible( False )
        axis.spines['right'].set_visible( False )
        yticks = axis.get_yticks()
        axis.set_yticks( yticks )
        axis.yaxis.set_major_formatter(FuncFormatter(lambda x, _: f'{int(x):d}'))
        axis.tick_params( axis='y', rotation=45 )
    
        if i < 2:
           axis.set_ylim( [0,50] )
        else:
           axis.set_ylim( [0,150] )
    
    #space between plots adjusted
    #plt.subplots_adjust(wspace=.15, hspace=0.25)
        
    return fig
