import sys
import os
import numpy as np

#------------------------------------------------------------------------------
sys.path.append(os.getcwd() + '/alglib')

#------------------------------------------------------------------------------
DATA_FILE    = 'frame[001][-0300].dat'
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
    frame_t = np.dtype( (np.uint16, (header['Width'][0],header['Height'][0]) ) ); # frame size derived from header
    frame = np.fromfile(infile, dtype = frame_t, count = 1)

    #-----------------
    print(header)
    frame.shape
    pass
    #-----------------
print(infile.closed)

#------------------------------------------------------------------------------

