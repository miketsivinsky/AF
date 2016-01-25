%--------------------------------------------------------------------------
close all;
clear all;

import alg_utils.*;

%--------------------------------------------------------------------------
JustImgGen = 0;
InDir      = 'D:\Mike\projects\OESD\A\data\in\';
FrameSize  = [800 600];
AlgSet1    = {  ...
                'ACMO', 'BREN', 'CONT', 'CURV', 'DCTE', ...
                'DCTR', 'GDER', 'GLVA', 'GLLV', 'GLVN', ...
                'GRAE', 'GRAT', 'GRAS', 'HELM', 'HISE', ...
                'HISR', 'LAPE', 'LAPM', 'LAPV', 'LAPD', ...
                'SFIL', 'SFRQ', 'TENG', 'TENV', 'VOLA', ...
                'WAVS', 'WAVV', 'WAVR' ...
             };
AlgSet2    = { 'BREN', 'GRAE', 'GRAT', 'GRAS', 'LAPE', 'LAPV', 'TENV', 'WAVV', 'WAVR' };
AlgSet3    = { 'TENV', 'WAVR' };

SizeROI1   = 256;
SizeROI2   = 128;
SizeROI3   =  64;
[ROI1,nROI1] = afGenVecROI(FrameSize, SizeROI1, [20 30]);
[ROI2,nROI2] = afGenVecROI(FrameSize, SizeROI2, [20 30]);
[ROI3,nROI3] = afGenVecROI(FrameSize, SizeROI3, [20 30]);
%ROI = [ROI1; ROI2; ROI3];
ROI = [ROI1;];

%--------------------------------------------------------------------------
JobList = struct( ...
                  'InDir',     [], ...
                  'OutDir',    [], ... 
                  'OutFile',   [], ...
                  'FrameSize', [], ...
                  'AlgNames',  [], ...
                  'ROI',       []  ...
                 );
            
JobListSize = size(ROI,1);
for j=1:JobListSize
    JobList(j).InDir     = InDir
    JobList(j).OutDir    = sprintf('../data/out/out%03d/',j);
    JobList(j).OutFile   = sprintf('outData%03d',j);
    JobList(j).FrameSize = FrameSize;
    JobList(j).AlgNames  = AlgSet3;
    JobList(j).ROI       = ROI(j,:);
end

JobList(1)

%--------------------------------------------------------------------------
jobIdxSet = [4:JobListSize];
%[res] = afJob(JobList,jobIdxSet,JustImgGen);