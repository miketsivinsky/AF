import sys
import os
import numpy as np

import time # for profiling only

#------------------------------------------------------------------------------
sys.path.append(os.getcwd() + '/alglib')

#------------------------------------------------------------------------------
DATA_FILE    = 'frame[050][+0190].dat'
AF_PATH      = os.environ['AF_PATH']
infile_name  = os.path.join(AF_PATH,'data','in',DATA_FILE)

print(infile_name)

#------------------------------------------------------------------------------
header_t = np.dtype([
    ("FileNum",          np.int32 ),
    ("LensControlValue", np.int32 ),
    ("ClassId",          np.uint32),
    ("MsgClassId",       np.uint32),
    ("NetSrc",           np.uint32),
    ("NetDst",           np.uint32),
    ("FrameNum",         np.uint32),
    ("PixelSize",        np.uint32),
    ("Height",           np.uint32),
    ("Width",            np.uint32),
])

with open(infile_name, 'rb') as infile:
    header = np.fromfile(infile, dtype = header_t, count = 1)
    #-----------------
    print(header)

    start_time = time.time()                                        # for profiling only
    frame = np.fromfile(infile, dtype = np.uint16)
    frame = frame.reshape((header['Height'][0],header['Width'][0]))
    d_time = time.time() - start_time                               # for profiling only
    print("elapsed time {0:6.4f} ms".format(d_time*1000))           # for profiling only
    print(frame.shape)


    pass
    #-----------------
print(infile.closed)

#------------------------------------------------------------------------------

