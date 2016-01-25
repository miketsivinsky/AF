%--------------------------------------------------------------------------
function [hAxes,hImg] = vesa_show(ImgMat,Title,Magnification)

hFig = figure;
hAxes = axes('DataAspectRatioMode','manual','PlotBoxAspectRatioMode','manual');
%hImg = imshow(ImgMat,[],'InitialMagnification',100,'XData',[0.5 size(ImgMat,2)+0.5],'YData',[0.5 size(ImgMat,1)+0.5]);
hImg = imshow(ImgMat,[],'InitialMagnification',Magnification,'XData',[1 size(ImgMat,2)],'YData',[1 size(ImgMat,1)]);
%hImg = imshow(ImgMat,[],'XData',[0.5 size(ImgMat,2)+0.5],'YData',[0.5 size(ImgMat,1)+0.5]);
hold on
title(Title);
set(gcf,'pointer','crosshair');
hPixelInfoPanel = impixelinfo(hImg);
%hDrangePanel = imdisplayrange(hImg);
%hpixreg = impixelregionpanel(hFig,hImg);
%set(hpixreg, 'units','normalized','position',[0.25 0.1 0.1 0.1])
%hAxes = gca;


