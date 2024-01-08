from netCDF4 import Dataset
import time, sys
import numpy as np
from scipy import integrate

data = Dataset('ch_cam300ri0_4096x64x64_3km_12s_cam300ri0_64_0000001800.nc','r')
temp = np.asarray(data.variables['TABS'])
qp = np.asarray(data.variables['QP'])
qv = np.asarray(data.variables['QV'])
cond = np.asarray(data.variables['QN'])
z = np.asarray(data.variables['z'])
del data

# calculate a buoyancy profile with two terms:
qv = qv/1000            # convert g kg-1 to kg kg-1
cond = cond/1000
g = 9.8
#tvP = temp*(1 + 0.608*qv)
tE = np.nanmean(temp)
qvE = np.nanmean(qv)
condE = np.nanmean(cond)
      # assume the environmental values are the spatial averages
term1 = g*(tvP - tvE)/tvE   # 0.00390946
#print 'Tv diff max, mean, min: ' + str(np.nanmax(tvP-tvE)) + \
#    str(np.nanmean(tvP-tvE)) + str(np.nanmin(tvP-tvE))
term2 = g*(cond - condE)    # 5.38813e-12
B = term1 + term2
print 'Buoyancy max, mean, min: ' + str(np.nanmax(B[0,0])) + ', ' + \
      str(np.nanmean(B[0,0])) + ', ' + str(np.nanmin(B[0,0]))
print 'Buoyancy shape: ' + str(B.shape)

# integrate the buoyancy profile up until the altitude where B 
# becomes negative
for xx in np.arange(4096):
    for yy in np.arange(64):
        indx = np.argwhere(B[0,:,yy,xx] < 0)[0][0]
        cape = integrate.simps(B[0,:indx,yy,xx],z[:indx])
        print B[0,:,yy,xx]
        print B[0,:indx,yy,xx]
        time.sleep(5)
        print cape
        print z[:indx]
        print '~~~~~~~~~~~~~~~~~~~~~~~'
        time.sleep(2)
print B[0,:,0,0]
