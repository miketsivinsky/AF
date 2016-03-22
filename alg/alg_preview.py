import sys
import os
import importlib          # for debub only

import numpy as np

#------------------------------------------------------------------------------
sys.path.append(os.getcwd() + '/alglib')
import alg_data_io  as alg_io
import alg_graphics as alg_gr
importlib.reload(alg_io)  # for debub only
importlib.reload(alg_gr)  # for debub only

#------------------------------------------------------------------------------
FRAME_HEIGHT = 600
FRAME_WIDTH  = 800

DATA_FILE    = 'frame[050][+0190].dat'
AF_PATH      = os.environ['AF_PATH']
infile_name  = os.path.join(AF_PATH,'data','in',DATA_FILE)
in_data = alg_io.read_infile(infile_name, Width = FRAME_WIDTH, Height = FRAME_HEIGHT)
#print(in_data.header, in_data.frame_size_valid)

#------------------------------------------------------------------------------
img_data = alg_gr.init_graphics(in_data.frame)
print(img_data.figure)

#------------------------------------------------------------------------------
alg_io.gen_list_ROI([FRAME_WIDTH, FRAME_HEIGHT])


