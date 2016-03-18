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
# see Python 3.5\Lib\site-packages\matplotlib\backend_bases.py - func mouse_move(self, event) for x,y [pixel value] ena/dis control

fig = plt.figure(frameon = True)
fig.canvas.set_window_title('slon')
ax  = fig.add_axes([0.1, 0.1, 0.8, 0.8])
ax.autoscale(tight = True)
ax.set_axis_off()                         # or use #ax.xaxis.set_visible(False) + #ax.yaxis.set_visible(False)
ax.format_coord = lambda x, y: ''
#ax.set_navigate(False)                   # disable navigate toolbar functions and disable coord and image pixel value dispaying
img = ax.imshow(out.frame, cmap = plt.cm.gray, origin = 'upper')
#img.format_cursor_data = lambda data: '' # not need
img.get_cursor_data = lambda event: None

ax.plot([10,100], [20,200])
ax.figure.show()


