#------------------------------------------------------------------------------
import numpy as np
from collections import namedtuple
import time            # for profiling only

#------------------------------------------------------------------------------
def read_infile(infile_name):
    """ read input data flie (file: header,frame) """

    # header format
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

    #open file, read header and frame
    with open(infile_name, 'rb') as infile:
        header = np.fromfile(infile, dtype = header_t, count = 1)
        #-----------------
        start_time = time.time()                                        # for profiling only
        frame = np.fromfile(infile, dtype = np.uint16)
        frame = frame.reshape((header['Height'][0],header['Width'][0]))
        d_time = time.time() - start_time                               # for profiling only
        print("elapsed time {0:6.4f} ms".format(d_time*1000))           # for profiling only
        # print(frame.shape)
    #print(infile.closed) # debug

    # return infile_data
    infile_data = namedtuple("infile_data",["header","frame"])
    return infile_data(header,frame)

