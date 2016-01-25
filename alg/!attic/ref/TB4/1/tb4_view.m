%img_file = '07-10-2010 20-44-16.tb4.IFrame009.png';
img_file = '07-10-2010 20-44-16.tb4.IFrame001.png';

figure;
Img = imread(img_file);
hImg = imshow(Img);
hPixelInfoPanel = impixelinfo(hImg);
hDrangePanel = imdisplayrange(hImg);
title(img_file);
set(gcf,'pointer','crosshair');
%imfinfo(img_file)


