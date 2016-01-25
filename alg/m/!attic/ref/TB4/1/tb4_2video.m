clear all;
inFile1 = 'SG_S2_full_nc_101_nearest_20x.avi';
inFile2 = 'SG_S2_full_nc_101_bilinear_20x.avi';
outFile = 'SG_S2_full_nc_101_nearest_vs_bilinear_20x.avi';

%---
clc;
tb4raw_data;
Stream_file_name =  RawData_ShootingGround_Sight2_17;
RawSourceFile = [RawDataFolder Stream_file_name];
LastDirSlashIdx  = find(RawSourceFile == '\',1,'last');
SrcDir = RawSourceFile(1:LastDirSlashIdx);
inFile1   = [SrcDir inFile1];
inFile2   = [SrcDir inFile2];
outFile = [SrcDir outFile];

%---
Channel1 = VideoReader(inFile1);
nFrames1 = Channel1.NumberOfFrames;
vidHeight1 = Channel1.Height;
vidWidth1  = Channel1.Width;

%---
Channel2 = VideoReader(inFile2);
nFrames2 = Channel2.NumberOfFrames;
vidHeight2 = Channel2.Height;
vidWidth2  = Channel2.Width;

%---
if(nFrames1 ~= nFrames2)
    fprintf(1,'nFrames1 (%5d) != nFrames2  (%5d)\n',nFrames1, nFrames2);
    return;
end    
if(vidHeight1 ~= vidHeight2)
    fprintf(1,'vidHeight1 (%3d) != vidHeight2  (%3d)\n',vidHeight1, vidHeight2);
    return;
end    
if(vidWidth1 ~= vidWidth2)
    fprintf(1,'vidWidth1 (%3d) != vidWidth2  (%3d)\n',vidWidth1, vidWidth2);
    return;
end    


%---
vidObj = VideoWriter(outFile,'Uncompressed AVI');
vidObj.FrameRate = 25;
open(vidObj);

%---
vBorderWidth = 40;
vBorder = zeros(vidHeight1, vBorderWidth, 3);
vBorder(:,vBorderWidth/2:vBorderWidth/2+1,2) = 100;
vBorder(:,vBorderWidth/2:vBorderWidth/2+1,3) = 100;

%---
Frame_start = 1;
Frame_num = nFrames1;
OldPercentFrameCount = 0;
for nFrame = Frame_start:Frame_num
    Frame1 = read(Channel1, nFrame);
    Frame2 = read(Channel2, nFrame);
    outFrame = cat(2,Frame1, vBorder, Frame2);
    writeVideo(vidObj,outFrame);
    PercentFrameCount = floor((nFrame - Frame_start + 1)*100/Frame_num);
    if((rem(PercentFrameCount,10) == 0) && (PercentFrameCount ~= OldPercentFrameCount))
        OldPercentFrameCount = PercentFrameCount;
        fprintf(1,'%3d%% frames processed\n',PercentFrameCount);
    end    

end    

close(vidObj);
fprintf(1,'\nEnd of processing\n');