#!/usr/bin/env ncplot
# Collocate an ERA-5 variable to MCSs in the given year and month
# var is assumed to be a string representing the variable to collocate.

def collocate_ERA5( year, month, var ):
    import xarray as xr
    import numpy as np
    import pandas as pd

    # Dictionary to map var to ERA5 variable name
    var_mapping = {
        "cape": "cape",
        "temperature": "t",
        "qv": "q",
        "qc": "clwc",
        "qi": "ciwc",
        "w": "vertical_velocity"
    }

    # Load ERA-5 data
    # [=] (744 times, 81 latitudes, 1440 longitudes), hourly and 0.25-deg resolution
    ERA_data = xr.open_dataset( '/xdisk/sylvia/ERA5_output/ERA5_' + var + '_tropical.nc' )

    # Set longitudes from 0 to 360 as in the ISCCP data
    var_name = var_mapping[var]
    ERA_data = ERA_data.assign_coords( longitude=(ERA_data['longitude'] % 360) )
    ERA_var = ERA_data[var_name]
    ERA_time = ERA_data['valid_time']

    # Load ISCCP CT data
    CT_data = np.load( '/groups/sylvia/JAS-MCS-rain/ISCCP/CT-allDataFilteredEdges_tropical.npy' )
    DD = np.zeros( (CT_data.shape[0],20) )
    DD[:,0] = CT_data[:,7]      # years
    DD[:,1] = CT_data[:,8]      # months
    DD[:,2] = CT_data[:,9]      # days
    DD[:,3] = CT_data[:,10]     # hours
    DD[:,4] = CT_data[:,21]     # 21 = core lat, 12 = sys lat
    DD[:,5] = CT_data[:,22]     # 22 = core lon, 13 = sys lon
    DD[:,6] = CT_data[:,37]     # land/water flag
    DD[:,7] = CT_data[:,2]      # maximum radius
    DD[:,8] = CT_data[:,3]      # minimum temp
    DD[:,9] = CT_data[:,5]      # lifetime 
    DD[:,10] = CT_data[:,11]     # CS radius
    DD[:,11] = CT_data[:,12]     # center lat
    DD[:,12] = CT_data[:,13]     # center lon
    DD[:,13] = CT_data[:,17]     # conv fraction
    DD[:,14] = CT_data[:,18]     # number of cores
    DD[:,15] = CT_data[:,24]     # CS temp
    DD[:,16] = CT_data[:,40]     # min latitude
    DD[:,17] = CT_data[:,41]     # max latitude
    DD[:,18] = CT_data[:,42]     # min longitude
    DD[:,19] = CT_data[:,43]     # max longitude

    # Collocate ERA data based upon the MCS center
    CT_lat = DD[:,11]
    CT_lon = DD[:,12]

    # Filter for systems in the tropics and in the year and month of interest
    DD = DD[(DD[:, 0] == year) & (DD[:, 1] == month)]

    # Initialize arrays to store results
    mean_var = []
    percentile99_var = []

    for ii in range(DD.shape[0]):
        #print( ii, DD.shape[0] )
        # Extract time, latitude, and longitude bounds for the current MCS
        mcs_time = f"{int(DD[ii, 0]):04d}-{int(DD[ii, 1]):02d}-{int(DD[ii, 2]):02d}T{int(DD[ii, 3]):02d}:00:00"
        
        # Set the precision to be the same as the ERA valid_times
        mcs_time = f"{mcs_time}.000000000"
        era_var_at_time = ERA_var.sel( valid_time=mcs_time, method="nearest" )
        
        min_lat, max_lat = DD[ii, 16], DD[ii, 17]
        min_lon, max_lon = DD[ii, 18], DD[ii, 19]

        # Handle longitude values exactly at 360.0
        if min_lon == 360.0:
           min_lon = 0.0
        if max_lon == 360.0:
           max_lon = 0.0
 
        # Handle cases where MCS spans the 0°/360° boundary
        if min_lon > max_lon:
           # Split into two longitude slices and combine
           part1 = era_var_at_time.sel( latitude=slice(max_lat, min_lat), longitude=slice(min_lon, 0) )
           part2 = era_var_at_time.sel( latitude=slice(max_lat, min_lat), longitude=slice(0, max_lon) )
           era_var_in_region = xr.concat( [part1, part2], dim="longitude" )
        else:
           # Normal case (no crossing 360° boundary)
           era_var_in_region = era_var_at_time.sel( latitude=slice(max_lat, min_lat), longitude=slice(min_lon, max_lon) )

        # Check if the selection is empty
        if era_var_in_region.size == 0 or np.all(np.isnan(era_var_in_region)):
           print(f"Warning: No valid ERA5 data found for MCS index {ii}. Skipping...")
           mean_var.append(np.nan)
           percentile99_var.append(np.nan)
           continue

        # Compute mean and 99th percentile values for the MCS region
        mean_var.append( era_var_in_region.mean().item() )
        percentile99_var.append( era_var_in_region.quantile(0.99).item() )

    dd_columns = [ "year", "month", "day", "hour", "core_lat", "core_lon", "land_water_flag",
               "max_radius", "min_temp", "lifetime", "cs_radius", "center_lat", "center_lon",
               "conv_fraction", "num_cores", "cs_temp", "min_lat", "max_lat", "min_lon", "max_lon" ]
    
    # Convert DD and CAPE statistics into a pandas DataFrame
    df = pd.DataFrame( DD, columns=dd_columns )
    df[var + "_mean"] = mean_var
    df[var + "_99"] = percentile99_var

    # Dynamically create the output file name with year and month
    year = int(DD[0, 0])
    month = int(DD[0, 1])
    output_file = f"/groups/sylvia/JAS-MCS-rain/ISCCP/CT_{var}_statistics_{year}_{month:02d}.csv"

    # Save the DataFrame to a CSV file
    df.to_csv( output_file, index=False )
    print( f"Data saved to {output_file}" )


if __name__ == "__main__":
    import sys

    # Check that the user provided the correct number of arguments
    if len(sys.argv) != 4:
        print( "Usage: python collocate_ERA5.py <year> <month> <variable>" )
        sys.exit(1)

    # Parse arguments
    year = int( sys.argv[1] )  # First argument is the year
    month = int( sys.argv[2] )  # Second argument is the month
    var = sys.argv[3]  # Third argument is the variable name (e.g., 'cape')

    # Call the function
    collocate_ERA5(year, month, var)

