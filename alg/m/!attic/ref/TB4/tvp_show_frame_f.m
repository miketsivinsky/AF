%--------------------------------------------------------------------------
function [hImg] =  tvp_show_frame_f(ftitle, frame, range)

hFig = figure;
hAx = axes('units','normalized','position',[0 .27 1 .70]);
if(numel(size(frame)) == 2)
    hImg = imshow(frame, range);
    colorbar
else    
    hImg = imshow(frame);
end    
title(ftitle);

hPixreg = impixelregionpanel(hFig,hImg);
set(hPixreg, 'Units','normalized','Position',[0.4 0.05 0.2 0.2]);

hPixelInfoPanel = impixelinfo(hImg);
set(gcf,'pointer','crosshair');


