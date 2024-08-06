# From environmental moisture to precipitation intensity 
The scripts in this repository look at relationships of environmental moisture, instability (convective available potential energy or CAPE), and precipitation intensity in both the ISCCP Convective Tracking dataset, collocated with synoptic conditions from the ERA-Interim reanalysis and the Multi-Source Weighted-Ensemble Precipitation (MSWEP) product), and long-channel radiative-convective equilibrium (RCE) simulations in the System for Atmospheric Modeling (SAM).

- *FigS\*.ipynb* - Jupyter Notebooks to reproduce supplemental figures, including 1) saturation fraction profiles from the tracking data, 2) PDFs of upper-tropospheric ascent from the tracking data, 3) scaling of mean/extreme mid-tropospheric ascent against CAPE for MCSs stratified by depth and 4) lifetime in the tracking data, 5) scaling of mean/extreme upper-tropospheric ascent against CAPE for MCSs stratified by extent in the tracking data, 6) PDFs of instantaneous and lifetime-minimum cloud-top temperatures, and 7) distributions of MCS extent across the two datasets.

- *Figures\_MCS-rainfall-article*.ipynb* - Jupyter Notebooks to reproduce article figures, including 0) PDFs of MCS precipitation across the two datasets, `Obs-Set' referring to figures generated from tracking data, and `RCE-Set' referring to figures generated from RCE simulations. For both `Obs-Set' and `RCE-Set', 1 = column saturation fraction (CSF)-precipitation relations, 2 = lower-tropospheric saturation deficit (SD)-CAPE relations, 3 = CAPE-ascent rate relations, and 4 = profiles and PDFs of condensate.

- *plotting\_utilities.py* - Series of Python functions related to plotting within the Jupyter Notebooks.

- *RCE-MCS-identification.ipynb* - Performs identification of MCSs within the RCE simulation output and extracts coincident CAPE, ascent rates, rainfall, condensate amounts, etc.

- *thermodynamic\_functions.py* - Series of Python functions related to thermodynamic calculations within the Jupyter Notebooks.

- *zero\_buoyancy\_plume.py* - Perform zero-buoyancy plume model calculations using the tracking data or RCE simulation output.
