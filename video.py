#!/usr/bin/env python
# CREATES A VIDEO OF THE RCE SIMULATION FIELDS
import warnings,matplotlib,sys
import matplotlib.cbook
warnings.filterwarnings("ignore",category=matplotlib.cbook.mplDeprecation)
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as ani
import matplotlib.cm as cm
from mpl_toolkits.basemap import Basemap,maskoceans
from netCDF4 import Dataset

prefix = 'ch_cam300ri0/ch_cam300ri0_4096x64x64_3km_12s_cam300ri0_64_'
rcesim = Dataset(prefix + '0000001800.nc','r')
qp = np.asarray(rcesim.variables['QP'])
varname = 'Surface precipitating condensate [g kg-1]'; short = 'qp_surf'

# plot a video of the field evolution
#ii = 172
fig = plt.figure()
ddcon = plt.pcolormesh(qp[0,0,:,:],shading='flat',cmap=cm.jet,vmin=0,vmax=2)
titre = (varname + ', t = day 1, hour 6')
plt.title(titre)
cbar = plt.colorbar(ddcon,orientation='horizontal',pad=0.15,shrink=0.8)
#plt.savefig('final_organization2.pdf')

def update_time(ii):
    global ddcon, titre
    print ii
    day = int(np.floor(ii/4))
    hour = np.mod(ii,4)*6
    file_index = str(ii*1800)
    num0 = 10 - len(file_index)
    zeros = ''; j = 0
    while j < num0:
          zeros = zeros + '0'
    print prefix + zeros + file_index
    rcesim = Dataset(prefix + zeros + file_index,'r')
    field = np.asarray(rcesim.variables['QP'])[0,0,:,:]
    ddcon = plt.pcolor(field,shading='flat',cmap=cm.jet,vmin=0,vmax=2)
    titre = varname + ', t = day ' + str(day) + ', hour ' + str(hour)
    plt.title(titre)
    print(titre)
    return titre,field,ii

vid = ani.FuncAnimation(fig,update_time,[ii for ii in range(1,101)],interval=2000,\
      repeat=False,blit=False)

ecrire = ani.writers['ffmpeg'](fps=5)
nombre = short +'.mp4'
vid.save(nombre,writer=ecrire,dpi=100)

plt.show()
