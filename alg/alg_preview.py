import sys
import os
import importlib          # for debub only
#import numpy as np

#------------------------------------------------------------------------------
sys.path.append(os.getcwd() + '/alglib')
import alg_data_io as alg_io
importlib.reload(alg_io)  # for debub only

#------------------------------------------------------------------------------
DATA_FILE    = 'frame[050][+0190].dat'
AF_PATH      = os.environ['AF_PATH']
infile_name  = os.path.join(AF_PATH,'data','in',DATA_FILE)
out = alg_io.read_infile(infile_name)

print(out.header)

