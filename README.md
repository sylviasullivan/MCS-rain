# From environmental moisture to precipitation intensity 
The scripts in this repository look at relationships of environmental moisture, instability (convecitve available potential energy or CAPE), and precipitation intensity in both observation-based product (ERA-Interim and ERA-5 reanalyses) and an idealized model (radiative convective equilibrium simulation).

- *clusterXYpoints.m* - MATLAB utility developed by others to identify which spatial points belong to a cluster

- *ERA5_CAPE_Pmax.m* - Read in the ERA-5 netcdf files and extract CAPE and precipitation intensity values for scaling

- *ERAI_CAPE_Pmax.m* - Read in the ERA-Interim netcdf files and extract CAPE and precipitation intensity values for scaling

- *ERA_RCE_scatter.m* - Scatterplot visualization of environmental variables from both ERA reanalysis and RCE simulations

- *ERA_binbySD_max.m*, *ERA_binbySD_stats.m* - Bin ERA environmental variables by saturation deficit (SD) returning either thier means or statistics

- *RCEchannel_CAPE.m*, *RCEchannel_CAPE_SST.m* - Visualize CAPE in the RCE channel as well as its difference from the mean + clustering component, generalizing for a range of sea surface temperatures

- *RCEchannel_collocation.m*, *RCEchannel_collocation_SST.m* - Collocate environmental variables in the RCE channel with a convective system, defined in the same manner as those used for the ERA-I and ERA-5 collocations, generalizing for a range of sea surface temperatures

- *RCEchannel_scatter.m* - Scatterplot visualizations of environmental variables from the RCE channel simulation
