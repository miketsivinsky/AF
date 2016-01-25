%--------------------------------------------------------------------------
function [res,algName,frameName] = algView(outFile, focusIdxSet)

import alg_utils.*;

%---
res           = [];
%bestFrameIdx  = [];
%bestFrameName = [];

%---
load(outFile);
algName = [];
if(~isempty(algName))
    numAlg = 1;
    algNum = find(strcmpi(algName,{outData.algName}));
     if(isempty(algNum))
        fprintf(1,'[ERROR] Alg %s is not exist in data log\n',algName);
        return;
     end    
    algSet = algNum:algNum;
else
    numAlg = numel(outData);
    algSet = 1:numAlg;
end
focusNum = numel(outData(1).focusArray(:));

%--------------------------------------------------------------------------

if(isempty(focusIdxSet))
    focusIdxSet = [1:focusNum];
end

focusSet      = outData(1).focusArray(focusIdxSet);
focusFunc     = zeros(numAlg,numel(focusIdxSet));
focusNormFunc = zeros(numAlg,numel(focusIdxSet));
normCompTime  = zeros(numAlg,1);
frameName     = {outData(1).fileNameArray(focusIdxSet,:)};
%bestFrameIdx  = cell(numAlg,1);
%bestFrameName = cell(numAlg,1);

fprintf(1,'----------------------------------\n');
fprintf(1,'ROI: [%3d %3d %3d %3d]\n',outData(1).ROI);

idx = 1;
for n = algSet
    focusFunc(idx,:) = outData(n).focusMeasureArray(focusIdxSet);
    focusNormFunc(idx,:) = outData(n).normFocusMeasureArray(focusIdxSet);
    normCompTime(idx) = outData(n).compTime/numel(outData(n).focusArray);
    %bestFrameIdx(idx)  = {find(focusNormFunc(idx,:) >= trsh)};
    %bestFrameName{idx} = cellstr(outData(n).fileNameArray(cell2mat(bestFrameIdx(idx)),:));
    %fprintf(1,'Alg(%2d): %5s, comp. time: %6.2f s\n',n,outData(n).algName,outData(n).compTime);
    idx = idx + 1;
end    

res = struct(...
              'NumAlg', numAlg, ...
              'FocusSet', focusSet, ...
              'FocusFunc', focusFunc, ...
              'FocusNormFunc', focusNormFunc, ...
              'NormCompTime', normCompTime ...
            );
algName = {outData(algSet).algName};

end