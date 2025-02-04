#!/usr/bin/env ncplot
# Collocate an ERA-5 variable to MCSs in the given year and month
# var is assumed to be a string representing the variable to collocate.

def collocate_ERA5_3D_core_vals( year, month, var ):
    import xarray as xr
    import numpy as np
    import pandas as pd
    import os

    # Dictionary to map var to ERA5 variable name
    var_mapping = {
        "cape": "cape",
        "temperature": "t",
        "qv": "q",
        "qc": "clwc",
        "qi": "ciwc",
        "w": "w"
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

    # Filter for systems in the tropics and in the year and month of interest
    DD = DD[(DD[:, 0] == year) & (DD[:, 1] == month)]
    
    # Prepare time and spatial boundaries
    times = [ f"{int(row[0]):04d}-{int(row[1]):02d}-{int(row[2]):02d}T{int(row[3]):02d}:00:00.000000000"
        for row in DD ]
    lat_bounds = np.stack( [DD[:, 16], DD[:, 17]], axis=1 )
    lon_bounds = np.stack( [DD[:, 18], DD[:, 19]], axis=1 )
    
    # Handle longitude wrapping (0°/360° boundary)
    lon_cross_mask = lon_bounds[:, 0] > lon_bounds[:, 1]
    lon_bounds[lon_cross_mask, 1] += 360  # Normalize crossing longitudes

    # Vectorized selection for ERA5 data
    results = []
    convective_vars = [
        "year", "month", "day", "hour",
        "core_lat", "core_lon", "land_water_flag", "max_radius", "min_temp", "lifetime",
        "cs_radius", "center_lat", "center_lon", "conv_fraction", "num_cores", "cs_temp",
        "min_lat", "max_lat", "min_lon", "max_lon"
    ]
    netcdf_file = f"/groups/sylvia/JAS-MCS-rain/ISCCP/colloc_{year}_NZ.nc"
    pp = 1
    for t, (min_lat, max_lat), (min_lon, max_lon) in zip(times, lat_bounds, lon_bounds):
        print( pp, len(times) )
        pp = pp + 1
        era_value = ERA_var.sel( latitude=core_lat, longitude=core_lon % 360, valid_time=t, method='nearest' )
        if era_value.size > 0 and not era_value.isnull().all():
            results.append(era_value.values)  # Append the nearest array (pressure levels)
        else:
            results.append(np.full_like(ERA_var.pressure_level.values, np.nan))  # Append NaNs

    # Create the DataFrame, including all variables from DD
    df = pd.DataFrame(DD[:, :len(convective_vars)], columns=convective_vars)

    if not os.path.exists(netcdf_file):
        # Create a new xarray Dataset and add all convective system properties
        ds = xr.Dataset(
            {
                **{var: (["occurrence"], df[var].values) for var in convective_vars},
                f"{var}": (["occurrence", "pressure_level"], np.array(results)),
            },
            coords={
                "occurrence": np.arange(len(df)),
                "pressure_level": ERA_var.pressure_level.values,
            },
        )
        ds.to_netcdf(netcdf_file)
        print(f"Created NetCDF file: {netcdf_file}")
    else:
        # Open the existing NetCDF file and append the new variables
        with xr.open_dataset(netcdf_file, mode="r+") as ds:
            for var in convective_vars:
                if var in ds:
                    # Append new values along the 'occurrence' dimension
                    existing_data = ds[var].values
                    new_data = np.concatenate([existing_data, df[var].values], axis=0)
                    ds[var] = xr.DataArray(new_data, dims=["occurrence"])
                else:
                    # Add the variable if it doesn't already exist
                    ds[var] = xr.DataArray(df[var].values, dims=["occurrence"])
    
            # Handle f"{var}"
            if f"{var}" in ds:
                # Append new mean values
                existing_vals = ds[f"{var}"].values
                new_vals = np.concatenate([existing_vals, np.array(results)], axis=0)
                ds[f"{var}"] = xr.DataArray( new_vals,
                    dims=["occurrence", "pressure_level"],
                    coords={ "occurrence": np.arange(len(new_vals)), "pressure_level": ERA_var.pressure_level.values, },
                )
            else:
                # Add mean values if they don't already exist
                ds[f"{var}"] = xr.DataArray( np.array(results),
                    dims=["occurrence", "pressure_level"],
                    coords={ "occurrence": np.arange(len(df)), "pressure_level": ERA_var.pressure_level.values, },
                )

            # Save changes to the NetCDF file
            ds.to_netcdf( netcdf_file, mode="a" )
            print(f"Appended data to existing NetCDF file: {netcdf_file}")


if __name__ == "__main__":
    import sys

    # Check that the user provided the correct number of arguments
    if len(sys.argv) != 4:
        print( "Usage: python collocate_ERA5_3D_core_vals.py <year> <month> <variable>" )
        sys.exit(1)

    # Parse arguments
    year = int( sys.argv[1] )  # First argument is the year
    month = int( sys.argv[2] )  # Second argument is the month
    var = sys.argv[3]  # Third argument is the variable name (e.g., 'cape')

    # Call the function
    collocate_ERA5_3D_core_vals(year, month, var)

