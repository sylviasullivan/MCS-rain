from netCDF4 import Dataset
import time, sys
import numpy as np
from scipy import integrate

data = Dataset('ch_cam300ri0_4096x64x64_3km_12s_cam300ri0_64_0000001800.nc','r')
temp = np.asarray(data.variables['TABS'])[0]
qv = np.asarray(data.variables['QV'])[0]
cond = np.asarray(data.variables['QN'])[0]
z = np.asarray(data.variables['z'])
del data

# calculate a buoyancy profile with two terms:
qv = qv/1000            # convert g kg-1 to kg kg-1
cond = cond/1000
g = 9.8
tvP = temp*(1 + 0.608*qv)
tvE = np.nanmean(np.nanmean(temp*(1 + 0.608*qv),axis=2),axis=1)
tvE2 = np.reshape(np.tile(tvE,(64,4096)),(64,64,4096))
del tvE

condE = np.nanmean(np.nanmean(cond,axis=2),axis=1)
      # assume the environmental values are the spatial averages
condE2 = np.reshape(np.tile(condE,(64,4096)),(64,64,4096))
del condE

term1 = g*(tvP - tvE2)/tvE2   # 0.00390946
print 'Tv diff max, mean, min: ' + str(np.nanmax(tvP-tvE2)) + \
    str(np.nanmean(tvP-tvE2)) + str(np.nanmin(tvP-tvE2))
term2 = g*(cond - condE2)    # 5.38813e-12
B = term1 + term2
print 'Buoyancy max, mean, min: ' + str(np.nanmax(B[0])) + ', ' + \
      str(np.nanmean(B[0])) + ', ' + str(np.nanmin(B[0]))
print 'Buoyancy shape: ' + str(B.shape)

# integrate the buoyancy profile up until the altitude where B 
# becomes negative
for xx in np.arange(4096):
    for yy in np.arange(64):
        indx = np.argwhere(B[:,yy,xx] < 0)[0][0]
        if indx > 1:
           cape = integrate.simps(B[:indx,yy,xx],z[:indx])
           print cape
           print '~~~~~~~~~~~~~~~~~~~~~~~'
           time.sleep(0.25)
