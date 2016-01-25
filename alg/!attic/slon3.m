%--------------------------------------------------------------------------
function slon3

close all;
clear all;
clc;

%--------------------------------------------------------------------------
AlgName   = 'GL1LV';
Th        = 0.995;
PointsSet = [1:50];

OutDir    = '.\out1\';
OutFile   = 'slondata';

%--------------------------------------------------------------------------
load([OutDir OutFile]);
PointsNum = numel( outData(1).focusArray(:));

algNum = find(strcmpi(AlgName,{outData.algName}));
if(isempty(algNum))
    fprintf(1,'[ERROR] Alg %s is not exist in data log\n',AlgName);
    return;
end    

return;

%--------------------------------------------------------------------------

%PointsSet = [1:PointsNum];
outData(algNum).algName
%outData(algNum).ROI
outData(algNum).compTime;
x = outData(algNum).focusArray(PointsSet);
%outData(algNum).fileNameArray(PointsSet,:)
y  = outData(algNum).focusMeasureArray(PointsSet);
yN = outData(algNum).normFocusMeasureArray(PointsSet);

bestFramesIdx = find(yN >= Th);
outData(algNum).fileNameArray(bestFramesIdx,:)
outData(algNum).normFocusMeasureArray(bestFramesIdx)

plot(x,yN,'r'); grid;

end