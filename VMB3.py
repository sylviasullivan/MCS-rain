#!/usr/bin/env mcsplot
# VMB2 script but using nc files
import sys,pickle,time
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from matplotlib.colors import SymLogNorm,LogNorm
from netCDF4 import Dataset,num2date
import pandas as pd
from scipy.interpolate import lagrange

def moving_average(a, n):
    ret = np.cumsum(a, dtype=float)
    ret[n:] = ret[n:] - ret[:-n]
    return ret[n-1:]/n

# calculate the buoyancy integrals
# assume that the lower bound is the sea surface rather than the LCL
g = 9.80655   # m s-2
sst1 = 295.6
sst2 = 295.2

# load all data year by year
basedir = '/rigel/home/scs2229/top-secret/MCS_clim/ausgabe/meteo_clim/nc/'

f1 = Dataset(basedir + 'colloc_ENDJFd1_ALL.nc','r+')
T1 = np.asarray(f1.variables['temperature'])    # (5018,32)
qv1 = np.asarray(f1.variables['qv'])
qc1 = np.asarray(f1.variables['qc'])
P1 = np.asarray(f1.variables['surface pressure'])

f2 = Dataset(basedir + 'colloc_LNDJFd1_ALL.nc','r+')
T2 = np.asarray(f2.variables['temperature'])
qv2 = np.asarray(f2.variables['qv'])
qc2 = np.asarray(f2.variables['qc'])
P2 = np.asarray(f2.variables['surface pressure'])

# create the average profile and its spread for all sets
alt = np.asarray([15418.43,14415.44,13470.22,12579.42,11739.87,10948.81,10191.54,\
       9458.63,8749.51,8064.40,7403.97,6769.08,6160.62,5579.46,5026.39,4502.09,\
       4007.11,3541.93,3106.86,2702.14,2327.89,1984.11,1670.7,1387.43,1133.93,\
       909.7,714.05,546.11,404.74,288.57,195.85,124.48])
press = np.asarray([122.6137,142.9017,165.0886,189.1466,215.0251,242.6523,272.0593,\
         303.2174,336.0439,370.4072,406.1328,443.0086,480.7907,519.2093,557.9734,\
         596.7774,635.3060,673.2403,710.2627,746.0635,780.3455,812.8303,843.2634,\
         871.4203,897.1118,920.1893,940.5511,958.1477,972.9868,985.1399,994.7472,\
         1002.0236])

# calculate the virtual temperature profiles for each depth and phase
Tv1 = T1*((0.622+qv1)/(0.622*(1+qv1)))
Tv2 = T2*((0.622+qv2)/(0.622*(1+qv2)))

# calculate the mean Tv over all systems and then perturbations
Tvmean1 = np.nanmean(T1)*((0.622+np.nanmean(qv1))/(0.622*(1+np.nanmean(qv1))))
Tvprime1 = Tv1 - Tvmean1
Tvmean2 = np.nanmean(T2)*((0.622+np.nanmean(qv2))/(0.622*(1+np.nanmean(qv2))))
Tvprime2 = Tv2 - Tvmean2

# calculate condensate perturbations
qcprime1 = qc1 - np.nanmean(qc1)
qcprime2 = qc2 - np.nanmean(qc2)

# buoyancy profiles = g Tv'/bar(Tv) - g l', [=] m2 s-1
B1 = g*Tvprime1/Tvmean1 - g*qcprime1
B2 = g*Tvprime2/Tvmean2 - g*qcprime2

# calculate a hydrostatic pressure reference
Rair = 287.058    # J kg-1 K-1
rhoAir = 1.2041   # this should be some empirical correlation w/ T, no?
psurf1 = rhoAir*Rair*sst1
psurf2 = rhoAir*Rair*sst2
#psurf = 101325
phydro1 = psurf1*np.exp(-g*alt/(Rair*Tv1))
phydro2 = psurf2*np.exp(-g*alt/(Rair*Tv2))

# calculate the perturbation from hydrostatic
pp1 = press*100 - phydro1
pp2 = press*100 - phydro2

# density of dry air and vertical gradient of pp
rho1 = press*100/(Rair*T1)
rho2 = press*100/(Rair*T2)

# calculate the vertical gradient of pressure perturbations
pf1 = np.zeros((rho1.shape[0],32))
pf2 = np.zeros((rho2.shape[0],32))
pfd1 = np.zeros((rho1.shape[0],32))
pfd2 = np.zeros((rho2.shape[0],32))
for kk in np.arange(rho1.shape[0]):
    cc = np.polyfit(alt,pp1[kk],4)
    pf1[kk] = cc[0]*alt**4 + cc[1]*alt**3 + cc[2]*alt**2 + cc[3]*alt + cc[4]
    pfpf = np.poly1d.deriv(np.poly1d(cc[:5]))
    pfd1[kk] = pfpf.c[0]*alt**3 + pfpf.c[1]*alt**2 + pfpf.c[2]*alt + pfpf.c[3]
    pfd1[kk] /= rho1[kk]

for kk in np.arange(rho2.shape[0]):
    cc = np.polyfit(alt,pp2[kk],4)
    pf2[kk] = cc[0]*alt**4 + cc[1]*alt**3 + cc[2]*alt**2 + cc[3]*alt + cc[4]
    pfpf = np.poly1d.deriv(np.poly1d(cc[:5]))
    pfd2[kk] = pfpf.c[0]*alt**3 + pfpf.c[1]*alt**2 + pfpf.c[2]*alt + pfpf.c[3]
    pfd2[kk] /= rho2[kk]
    
np.save('/rigel/home/scs2229/top-secret/MCS_clim/scripts/figs/dragEN_surfp.npy',pfd1)
np.save('/rigel/home/scs2229/top-secret/MCS_clim/scripts/figs/dragLN_surfp.npy',pfd2)
np.save('/rigel/home/scs2229/top-secret/MCS_clim/scripts/figs/buoyEN_surfp.npy',B1)
np.save('/rigel/home/scs2229/top-secret/MCS_clim/scripts/figs/buoyLN_surfp.npy',B2)
sys.exit()

# plot the buoyancy profiles
fs = 10
y1 = 300   # 122
y2 = 1002
fig = plt.figure(figsize=(11,7.5))
ax1 = plt.subplot2grid((2,3),(0,0))
ax1.plot(np.transpose(B1),press,linewidth=0.5)
ax1.plot(np.nanmean(B1,axis=0),press,linewidth=1.25,color='k')
ax1.plot([0,0],[y1,y2],color='k',linestyle='--',linewidth=0.75)
ax1.tick_params(axis='both',labelsize=fs)
plt.xlabel(r'El Ni$\~n$o buoyancy [m s$^{-2}$]'); plt.ylabel('P [hPa]')
plt.text(0.05,0.9,'(a)',fontsize=fs,fontweight='bold',transform=ax1.transAxes)
ax1.set_ylim([y1,y2])
ax1.set_xlim([-3,2])
ax1.invert_yaxis()

ax2 = plt.subplot2grid((2,3),(0,1))
ax2.plot(np.transpose(B2),press,linewidth=0.5)
ax2.plot(np.nanmean(B2,axis=0),press,linewidth=1.25,color='k')
ax2.plot([0,0],[y1,y2],color='k',linestyle='--',linewidth=0.75)
ax2.tick_params(axis='both',labelsize=fs)
plt.xlabel(r'La Ni$\~n$a buoyancy [m s$^{-2}$]')
plt.text(0.05,0.9,'(b)',fontsize=fs,fontweight='bold',transform=ax2.transAxes)
ax2.set_ylim([y1,y2])
ax2.set_xlim([-3,2])
ax2.invert_yaxis()

ax3 = plt.subplot2grid((2,3),(0,2))
ax3.plot(moving_average((np.nanmean(B1,axis=0)-np.nanmean(B2,axis=0))/np.nanmean(B2,axis=0)*100.,3),\
    moving_average(press,3),linewidth=1.25,color='k')
ax3.plot([0,0],[y1,y2],color='k',linestyle='--',linewidth=0.75)
plt.text(0.05,0.9,'(c)',fontsize=fs,fontweight='bold',transform=ax3.transAxes)
plt.xlabel(r'(EN-LN)/LN $\Delta$ B [%]')
ax3.set_ylim([y1,y2])
ax3.invert_yaxis()

ax4 = plt.subplot2grid((2,3),(1,0))
ax4.plot(np.transpose(pfd1[:200:]),alt/1000,linewidth=0.5)
ax4.plot(np.nanmean(pfd1,axis=0),alt/1000,linewidth=1.25,color='k')
ax4.plot([0,0],[0,15],color='k',linestyle='--',linewidth=0.75)
plt.ylim([0,10])
ax4.set_xlim([-1,2])
ax4.tick_params(axis='both',labelsize=fs)
plt.xlabel(r'El Ni$\~n$o pressure '
           '\n'
           r'gradient force [m s$^{-2}$]')
plt.ylabel('z [km]')
plt.text(0.05,0.9,'(d)',fontsize=fs,fontweight='bold',transform=ax4.transAxes)

ax5 = plt.subplot2grid((2,3),(1,1))
ax5.plot(np.transpose(pfd2[:200:]),alt/1000,linewidth=0.5)
ax5.plot(np.nanmean(pfd2,axis=0),alt/1000,color='k',linewidth=1.25)
ax5.plot([0,0],[0,10],color='k',linestyle='--',linewidth=0.75)
plt.ylim([0,10])
ax5.set_xlim([-1,2])
ax5.tick_params(axis='both',labelsize=fs)
plt.xlabel(r'La Ni$\~n$a pressure '
           '\n'
           r'gradient force [m s$^{-2}$]')
plt.text(0.05,0.9,'(e)',fontsize=fs,fontweight='bold',transform=ax5.transAxes)

ax6 = plt.subplot2grid((2,3),(1,2))
ax6.plot((np.nanmean(pfd1,axis=0)-np.nanmean(pfd2,axis=0))/np.nanmean(pfd2,axis=0)*100.,\
    alt/1000,linewidth=1.25,color='k')
ax6.plot([0,0],[0,10],color='k',linestyle='--',linewidth=0.75)
plt.text(0.05,0.9,'(f)',fontsize=fs,fontweight='bold',transform=ax6.transAxes)
ax6.set_ylim([0,10])
ax6.set_xlim([-5,7.5])
plt.xlabel(r'(EN-LN)/LN $\Delta$ PGF [%]')
#fig.savefig('/rigel/home/scs2229/top-secret/MCS_clim/ausgabe/meteo_clim/dragBuoyd1_VMB3.pdf',bbox_inches='tight')
plt.show()
