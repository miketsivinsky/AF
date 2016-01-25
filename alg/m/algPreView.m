%--------------------------------------------------------------------------
clc;
close all;
clear all;
import alg_utils.*

%--------------------------------------------------------------------------
DataDir  = 'D:\Mike\projects\OESD\A\data\in\';
DataFile = 'frame[050][+0190]';
Alg = 'TENG';

FrameSizeX = 800;
FrameSizeY = 600;
SizeROI1    = 64;
SizeROI2    = 128;
SizeROI3    = 256;
[ROI1,nROI1] = afGenVecROI([FrameSizeX FrameSizeY], SizeROI1, [20 30]);
[ROI2,nROI2] = afGenVecROI([FrameSizeX FrameSizeY], SizeROI2, [20 30]);
[ROI3,nROI3] = afGenVecROI([FrameSizeX FrameSizeY], SizeROI3, [20 30]);
%ROI = [ROI1; ROI2; ROI3];
ROI = [ROI2];

%--------------------------------------------------------------------------
Monitor    = 2;
ImgScale   = 64;
FileSfx    = 'dat';
ImgSfx     = 'png';

%--------------------------------------------------------------------------
fileName = [DataDir DataFile '.' FileSfx];
[status, frame, lensControl] = readDataFile(fileName,FrameSizeX,FrameSizeY);
if(status ~= 1)
    fprintf(1,'[ERROR] readDataFile\n');
    return;
end

%---
[hImg, hAxes, cMap] = initGraphics(frame);
hMon = get(0,'MonitorPositions');
figPos = hMon(Monitor,:);
figPos(3) = figPos(3) - figPos(1) + 1;
figPos(4) = figPos(4) - figPos(2) + 1;
set(gcf,'units','pixels','outerposition',figPos);

imwrite(frame*ImgScale,[DataFile '.' ImgSfx],ImgSfx);

nROI = size(ROI,1);
for n = 1:nROI
    sX = ROI(n,1);
    sY = ROI(n,2);
    eX = sX + ROI(n,3)-1;
    eY = sY + ROI(n,4)-1;
    plotBorder(hAxes,sX,sY,(eX-sX+1),(eY-sY+1),'b',[]);
    fName = sprintf('r-%s[%3d %3d %3d %3d].%s',DataFile,ROI(n,:),ImgSfx);
    sFrame = frame(sY:eY,sX:eX);
    imwrite(sFrame*ImgScale,fName);
    fm = fmeasure(sFrame,Alg,[]);
    fprintf(1,'Alg: %s, ROI[%d]: [%3d %3d %3d %3d], fm: %6.2f\n',Alg,n,ROI(n,:),fm);
    cStr = sprintf('[%1d]  %6.1f',n,fm);
    text(sX+10,sY+10,cStr,'Color',[1 0 0],'FontSize',12,'EdgeColor',[0.8 0.4 0]);
    clear sFrame;
end    

%ROIsizeX   = 128;
%ROIsizeY   = 128;
%[sX, eX, sY, eY] = getCenterZoneCrd(FrameSizeX, FrameSizeY, ROIsizeX, ROIsizeX);


