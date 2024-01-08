# Precipitation Extremes in Tropical Mesoscale Storms

## Exploration of hydrological properties in organised clouds in the subtropics.

This repository contains Jupyter notebooks which explore various properties of cloud systems in the subtropics. An important part of the project is evaluating the disparity between mean  and maximal precipitation behaviour as functions of convective available potential energy (CAPE). We expect to find threshold behaviour in the mean, which increases in the mean and 95th percentiles, but chaotic and then decreasing behaviour in the 99th percentile and maximum values respectively. Also, precipitation is explored here as a property of column water vapour content (CWVC), where a non linear profile is expected to be found. 

## File descriptions

RCE_COL_XR_FINISHED is the finalised script for treating the raw output from the RCE simulations and creating new xr arrays for the environmental variables collocated with the clusters that have been identified

COL_RCE_ANALYSIS and RCE_ANALYSIS show the same information really, but RCE_ANALYSIS has been updated with some different plotting parameters in some cases and a more extensive consideration of precipitation vs pressure velocity over multiple z-levels. Both show analagous consideration of CAPE, CWVC, Saturation deficit, precipitation intensity and pressure velocity, also over the different vertical levels. Here we observe clear stratification based on 

RCE_COL_ROUGH_XR and RCE_COL_ROUGH should be ignored, they were rough drafts for the finalised code.

era1_cape_pmax_function-main has binning and analysis of precipitation intensity, CAPE and pressure velocity. Some valuable analysis in pressure velocity vs CAPE and considering this over the different pressure levels.

era_5_cape_pmax_functions precipitation against cape, cwvc, pressure velocity vs cape, (-ve and +ve pressure velocity vs cape), precipitation intensity against pressure velocity ( shows reduction in precip at zero pressure velocity but maximum in the max precipitation), then consideration of cape vs saturation deficit, relative humidity and CWVC. 

*thermodynamic_functions* contains functions to calculate saturation vapor pressure with respect to liquid and ice, potential temperature, relative humidity with respect to ice, and running means.
*precipConversion is a function to convert rain mass mixing ratio to rain rate
*wConversion is a function to convert w to omega

clusters.mp4 shows the identified storm clusters for sst 300 ( I think ), over all 30 minute intervals. Quite hectic but does show some grouping in time and space. 

