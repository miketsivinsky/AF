#------------------------------------------------------------------------------
import matplotlib.pyplot as plt
import screeninfo
from collections import namedtuple

#------------------------------------------------------------------------------
def init_graphics(img_buf):
    """ create figure and axes, show image """

    fig = plt.figure(frameon = True)
    fig.canvas.set_window_title('slon')
    ax  = fig.add_axes([0.0, 0.0, 1.0, 1.0])
    ax.autoscale(tight = True)
    ax.set_axis_off()                         # or use #ax.xaxis.set_visible(False) + #ax.yaxis.set_visible(False)
    ax.format_coord = lambda x, y: ''
    #ax.set_navigate(False)                   # disable navigate toolbar functions and disable coord and image pixel value dispaying
    img = ax.imshow(img_buf, cmap = plt.cm.gray, origin = 'upper')
    #img.format_cursor_data = lambda data: '' # not need
    img.get_cursor_data = lambda event: None

    monitors = screeninfo.get_monitors()

    ax.figure.show()

    img_data = namedtuple("img_data",["figure","axes","image","monitors"])
    return img_data(fig,ax,img,monitors)

