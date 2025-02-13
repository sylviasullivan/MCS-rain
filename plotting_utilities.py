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
from scipy import stats
from scipy.stats import pearsonr, zscore

from scipy.optimize import curve_fit
from matplotlib.ticker import FuncFormatter

plt.rcParams.update({'font.size': 12})

warnings.filterwarnings(action='ignore')

def RCE_concat( input_arrays, var ):
    return np.concatenate( [ii[var].to_numpy() for ii in input_arrays], axis=0 )

def read_RCE_files_cg( path ):
    mean_300 = xr.open_dataset( path + 'RCE_COL_MEAN_300_cg.nc' )
    p99_300 = xr.open_dataset( path + 'RCE_COL_99_300_cg.nc' )
    clusters_300 = xr.open_dataset( path + 'RCE_COL_cluster-sizes_300_cg.nc' )
    rad_300 = []
    for c in clusters_300['cluster_sizes'].values:
        rad_300.append( 2*(c*9/np.pi)**(0.5) )
    
    return mean_300, p99_300, rad_300

def read_RCE_files( path ):
    mean_290 = xr.open_dataset( path + 'RCE_COL_MEAN_290.nc' )
    mean_295 = xr.open_dataset( path + 'RCE_COL_MEAN_295.nc' )
    mean_300 = xr.open_dataset( path + 'RCE_COL_MEAN_300.nc' )
    mean_305 = xr.open_dataset( path + 'RCE_COL_MEAN_305.nc' )
    mean_310 = xr.open_dataset( path + 'RCE_COL_MEAN_310.nc' )
    means = [ mean_290, mean_295, mean_300, mean_305, mean_310 ]
    
    p99_290 = xr.open_dataset( path + 'RCE_COL_99_290.nc' )
    p99_295 = xr.open_dataset( path + 'RCE_COL_99_295.nc' )
    p99_300 = xr.open_dataset( path + 'RCE_COL_99_300.nc' )
    p99_305 = xr.open_dataset( path + 'RCE_COL_99_305.nc' )
    p99_310 = xr.open_dataset( path + 'RCE_COL_99_310.nc' )
    p99s = [ p99_290, p99_295, p99_300, p99_305, p99_310 ]
    
    clusters_290 = xr.open_dataset( path + 'RCE_COL_cluster-sizes_290.nc' )
    clusters_295 = xr.open_dataset( path + 'RCE_COL_cluster-sizes_295.nc' )
    clusters_300 = xr.open_dataset( path + 'RCE_COL_cluster-sizes_300.nc' )
    clusters_305 = xr.open_dataset( path + 'RCE_COL_cluster-sizes_305.nc' )
    clusters_310 = xr.open_dataset( path + 'RCE_COL_cluster-sizes_310.nc' )
    
    clusters = [clusters_290, clusters_295, clusters_300, clusters_305, clusters_310]
    rad = []
    for c in clusters:
        rad.append( 2*(c['cluster_sizes']*9/np.pi)**(0.5) )
    
    return means, p99s, rad

# Evaluate the correlation coefficient between precip efficiency and var.
# i are the tropical lat/lon indices and those for which omega < 0. 
# precipeff are the precipitation efficiencies
def pe_cc(var, precipeff):
    
    #var_nc = negative_to_nan( var )[i[:,0]] - previously when i was the second input above
    var_nc = var
    j = np.argwhere( (precipeff > 0) & (zscore(var_nc, nan_policy='omit') <= 2) )
    ref = stats.pearsonr( var_nc[j[:,0]], precipeff[j[:,0]] )
    return ref    

# Defines the appropriate indices for calculating a linear regression between x and y
# and then calculates it
def linindx(x, y):
    mean_y = np.nanmean(y)
    std_y = np.nanstd(y)
    zscores = np.abs((y - mean_y) / std_y)
    i = np.argwhere( ~np.isnan(x) & ~np.isnan(y) & (zscores < 2) )
    x_input = x[i[:,0]]
    out = stats.linregress( x=x[i[:,0]], y=y[i[:,0]] )
    y_predicted = x_input*out.slope + out.intercept
    return out, y_predicted, x_input, zscores

# Files to access NetCDF data and store cape and precipitation into numpy arrays
def file_concatenator_ERAI(numerical_list):
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


def file_concatenator_ERA5_NZ(numerical_list):
    #Takes a list of numbers corresponding to filenumbers/years
    #and compiles the corresponding list of filenames
    file_names = []

    #base directory where the desired files are located
    basedir = '/groups/sylvia/JAS-MCS-rain/ERA5/'

    #iterates through numbers
    for value in numerical_list:
        #appending list of files
        file_names = np.append(file_names,(basedir + 'colloc5_' + str(value) + '_NZ.nc'))

    return file_names


def file_concatenator_ERA5(numerical_list):
    #Takes a list of numbers corresponding to filenumbers/years
    #and compiles the corresponding list of filenames
    file_names = []

    #base directory where the desired files are located
    basedir = '/groups/sylvia/JAS-MCS-rain/ERA5/'

    #iterates through numbers
    for value in numerical_list:
        #appending list of files
        file_names = np.append(file_names,(basedir + 'colloc5_' + str(value) + '.nc'))

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
