import sys
import os
import importlib          # for debub only

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

#------------------------------------------------------------------------------
sys.path.append(os.getcwd() + '/alglib')
import alg_data_io as alg_io
importlib.reload(alg_io)  # for debub only

#------------------------------------------------------------------------------
FRAME_HEIGHT = 600
FRAME_WIDTH  = 800

DATA_FILE    = 'frame[050][+0190].dat'
AF_PATH      = os.environ['AF_PATH']
infile_name  = os.path.join(AF_PATH,'data','in',DATA_FILE)
out = alg_io.read_infile(infile_name, Width = FRAME_WIDTH, Height = FRAME_HEIGHT)

#------------------------------------------------------------------------------
print(out.header, out.frame_size_valid)

#------------------------------------------------------------------------------
fig = plt.figure()
ax  = fig.add_axes([0, 0, 1, 1])
ax.imshow(out.frame, cmap = plt.cm.gray)
#ax.imshow(out.frame, cmap = plt.cm.gray, extent = [0, 800, 600, 0])
fig.show()



