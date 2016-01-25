%--------------------------------------------------------------------------
function [] = plot_fborder(hAxesFrame,x0,y0,x1,y1,bcolor)

Ysize = y1 - y0 + 1;
Xsize = x1 - x0 + 1;

line_left_vert_X = ones(1,Ysize)*x0;
line_left_vert_Y = y0:y1;

line_right_vert_X = ones(1,Ysize)*x1;
line_right_vert_Y = y0:y1;

line_top_hor_X    = x0:x1;
line_top_hor_Y    = ones(1,Xsize)*y0;

line_bottom_hor_X = x0:x1;
line_bottom_hor_Y = ones(1,Xsize)*y1;

plot(hAxesFrame,line_left_vert_X,line_left_vert_Y,bcolor);
plot(hAxesFrame,line_right_vert_X,line_right_vert_Y,bcolor);
plot(hAxesFrame,line_top_hor_X,line_top_hor_Y,bcolor);
plot(hAxesFrame,line_bottom_hor_X,line_bottom_hor_Y,bcolor);
