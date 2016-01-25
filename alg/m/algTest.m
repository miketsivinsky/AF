%--------------------------------------------------------------------------
clear all;
close all;
clc;
import alg_utils.*;

%--------------------------------------------------------------------------
PlotNormFocusFunc = 1;
PlotBestFocus     = 1;

%---
DataSetNum = 2;
DataSets = [1:6];
AlgSet      = { 'BREN','GLVA', 'WAVV' }; % {'BREN', 'TENV'};
FocusIdxSet = [1:70];  %[1:110];

%---
ReperXL     = 170;
ReperX0     = 220;
ReperXR     = 250;

%---
if(isempty(DataSets))
    DataSets = 1:DataSetNum;
else 
    DataSetNum = DataSets(end);
end    
OutFileSet = cell(DataSetNum,1);
for i=DataSets
    OutFileSet{i} = sprintf('../data/out/out%03d/outData%03d',i,i);
end    

Monitor     = 2;
BgColor = [0.2 0.2 0.2];
ColorArray = [ ...
                 0.0 0.0 0.8;
                 0.0 0.8 0.0;
                 0.8 0.0 0.0;
                 0.0 0.8 0.8;
                 0.8 0.0 0.8;
                 0.8 0.8 0.0;
                 0.0 0.0 1.0;
                 0.0 1.0 0.0;
                 1.0 0.0 0.0;
                 0.0 1.0 1.0;
                 1.0 0.0 1.0;
                 1.0 1.0 0.0;
             ];
MarkerArray    = ['+', '*', 'o', '.', 'x', 's', 'd', 'p', 'h'];
LineStyleArray = {':', '-', '-.', '--'};
sizeColorArray = size(ColorArray,1);
sizeMarkerArray = size(MarkerArray,2);
sizeLineStyleArray = size(LineStyleArray,2);

%--------------------------------------------------------------------------
gblGraphExist = 0;
YMax = 0;
j = 1;
bestFocusVec = zeros(1,numel(DataSets));

for k = DataSets
    fprintf(1,'**********************************\n');
    fprintf(1,'DataSet: %2d\n',k);
    [res,algName,frameName] = algView(char(OutFileSet(k)),FocusIdxSet);
    strFrameName = char(frameName);
    algSetIdx = zeros(1,numel(AlgSet));
    
    %---
    fprintf(1,'----------------------------------\n');
    lineStyleIdx = rem(k,sizeLineStyleArray)+1;
    i = 1;
    for n = 1:res.NumAlg
        colorIdx = rem(n,sizeColorArray)+1;
        markerIdx = rem(n,sizeMarkerArray)+1;
        if(sum(strcmpi(char(algName(n)),AlgSet)) || isempty(AlgSet))
            x = res.FocusSet;
            y     = res.FocusFunc(n,:);
            yNorm = res.FocusNormFunc(n,:);
            yNormMax = max(yNorm);
            xMaxIdx = find(yNorm == yNormMax,1);
            if(i == 1)
                bestFocusVec(j) = x(xMaxIdx);
            end    
            yMax = y(xMaxIdx);
            if(yMax > YMax)
                YMax = yMax;
            end    
            fName = strFrameName(xMaxIdx,:);
            fprintf(1,'Alg selected: %2d, %s [%8.2f ms]. Best focus at: %5d, %6.2f/%6.2e, %s\n',n,char(algName(n)),1000*res.NormCompTime(n),x(xMaxIdx),yNormMax,yMax,fName);
            %fprintf(1,'Alg selected: %2d, %s [%6.2f ms]. Best focus at: %5d, %6.2f, %s\n',n,char(algName(n)),1000*res.NormCompTime(n),-1,0,'s');
            if(PlotNormFocusFunc)
                yGraph = yNorm;
            else
                yGraph = y;
            end    
            hPlot = plot(x,yGraph,...
                         'Color',ColorArray(colorIdx,:), ...
                         'Marker',MarkerArray(markerIdx), ...
                         'LineStyle',LineStyleArray{lineStyleIdx} ...
                         );
            %get(hPlot)
            hold on;
            algSetIdx(i) = n;
            i = i+1;
        end    
    end
    j = j+1;
    fprintf(1,'\n');
    
    %---
    isGraphExist = sum(algSetIdx);
    if(isGraphExist)
        gblGraphExist = 1;
        h = legend(algName(algSetIdx),'Location','NorthEastOutside','Color',BgColor,'TextColor',[1 1 1]);
    end

end    

if(gblGraphExist)
    if(PlotNormFocusFunc)
        YLim = [0 1.025];
    else
        YLim = [0 YMax*1.025];
    end    
    %--- reper (best sharpness)
    refX0 = linspace(ReperX0,ReperX0);
    refXL = linspace(ReperXL,ReperXL);
    refXR = linspace(ReperXR,ReperXR);
    refY = linspace(YLim(1),YLim(2));
    plot(refX0,refY,'m--');
    plot(refXL,refY,'r--');
    plot(refXR,refY,'r--');

    %---
    grid;
    set(gca,'XLim',[res.FocusSet(1) res.FocusSet(end)],'YLim',YLim, 'Color',BgColor);
    hMon = get(0,'MonitorPositions');
    figPos = hMon(Monitor,:);
    figPos(3) = figPos(3) - figPos(1) + 1;
    figPos(4) = figPos(4) - figPos(2) + 1;
    set(gcf,'units','pixels','outerposition',figPos);

    N  = numel(bestFocusVec);
    N1 = numel(find((bestFocusVec >= ReperXL) & (bestFocusVec <= ReperXR)));
    N2 = numel(find((bestFocusVec >= ReperX0-10) & (bestFocusVec <= ReperX0+10)));
    fprintf(1,'K1: %6.3f, K2: %6.3f\n',N1/N,N2/N);
    
    if(PlotBestFocus)
        figure;
        xVec = 1:numel(bestFocusVec);
        refX0 = ones(size(xVec))*ReperX0;
        refXL = ones(size(xVec))*ReperXL;
        refXR = ones(size(xVec))*ReperXR;
        stem(xVec,bestFocusVec,'y');
        hold on;
        plot(xVec,refX0,'g--');
        plot(xVec,refXL,'r--');
        plot(xVec,refXR,'r--');
        set(gca,'XLim',[xVec(1)-0.5 xVec(end)+0.5],'Color',[0.0 0.4 0.6]);
        grid;
    end    
end    





