%--------------------------------------------------------------------------
function slon2

close all;
clear all;
import alg_utils.*;

%--------------------------------------------------------------------------
FrameSizeX = 800;
FrameSizeY = 600;
ROIsizeX   = 128;
ROIsizeY   = 128;

InDir    = 'E:\projects\OESD\A\bin\log\';
OutDir   = '.\out\';
OutFile  = 'slondata';
AlgNames = {'GLVA', 'GLLV'};

%--------------------------------------------------------------------------
clc;
inFileList = dir(InDir);
inFileList = inFileList([inFileList.isdir] == 0);
inFileNum = numel(inFileList);
algNum = numel(AlgNames);
[sX, eX, sY, eY] = getCenterZoneCrd(FrameSizeX, FrameSizeY, ROIsizeX, ROIsizeY);
ROI = [sX, sY, eX, eY];

outData(1:algNum) = struct( ...
                                'algName',               [], ...
                                'ROI',                   ROI, ...
                                'compTime',              0, ...
                                'focusArray',            zeros(1,inFileNum), ...
                                'fileNameArray',         char({inFileList.name}), ...
                                'focusMeasureArray',     zeros(1,inFileNum), ...
                                'normFocusMeasureArray', zeros(1,inFileNum) ...
                           );

%--------------------------------------------------------------------------
for n = 1:algNum
    outData(n).algName = char(AlgNames(n));
end

fprintf(1,'[INFO] job start\n');
fprintf(1,'[INFO] inFileNum: %4d\n',inFileNum);
fprintf(1,'[INFO] algNum:    %4d\n',algNum);

%--------------------------------------------------------------------------
for k = 1:inFileNum
    fileName = [InDir inFileList(k).name];
    [status, frame, lensControl] = readDataFile(fileName,FrameSizeX,FrameSizeY);
    if(status ~= 1)
        fprintf(1,'[ERROR] file %20s read\n',inFileList(k).name);
        return;
    end
    sFrame = frame(sY:eY,sX:eX);
    clear frame;
    
    %---
    for n = 1:algNum
        outData(n).focusArray(k) = lensControl;
        tStart = tic;
        %--- compute func focus
        fm = fmeasure(sFrame,outData(n).algName,[]);
        %---
        outData(n).compTime = outData(n).compTime + toc(tStart);
        outData(n).focusMeasureArray(k) = fm;
    end
    clear sFrame;
end

%---
for n = 1:algNum
    maxFuncFocus = max(outData(n).focusMeasureArray(:));
    outData(n).normFocusMeasureArray = outData(n).focusMeasureArray/maxFuncFocus;
end

save([OutDir OutFile],'outData');
clear outData;

fprintf(1,'[INFO] job completed\n');

end

%--------------------------------------------------------------------------
