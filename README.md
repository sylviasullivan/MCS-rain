# From environmental moisture to precipitation intensity 
The scripts in this repository look at relationships of environmental moisture, instability (convecitve available potential energy or CAPE), and precipitation intensity in both observation-based product (ERA-Interim and ERA-5 reanalyses) and an idealized model (radiative convective equilibrium simulation).

*clusterXYpoints.m* - MATLAB utility developed by others to identify which spatial points belong to a cluster

*ERA5_CAPE_Pmax.m* - Read in the ERA-5 netcdf files and extract CAPE and precipitation intensity values for scaling

*ERAI_CAPE_Pmax.m* - Read in the ERA-Interim netcdf files and extract CAPE and precipitation intensity values for scaling

*RCEchannel_CAPE.m* - Visualize CAPE in the RCE channel as well as its difference from the mean, clustering component also

*RCEchannel_CAPE_SST.m* - Visualize CAPE in the RCE channel as well as its difference from the mean, clustering component also, generalizes *RCEchannel_CAPE_SST.m* for a range of different sea surface temperatures

*RCEchannel_collocation.m* - Collocate environmental variables in the RCE channel with a convective system, defined in the same manner as those used for the ERA-I and ERA-5 collocations

*RCEchannel_scatter.m* - Scatterplot visualizations of environmental variables from the RCE channel simulation
