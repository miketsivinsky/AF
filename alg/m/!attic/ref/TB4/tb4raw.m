%clear classes;
%clc;

%--- read info about folders containing raw data
%tb4raw_data;

%--- read script parameters
%tb4raw_params;
if(V_Channels(1:2)  == [0 0])
    fprintf(1,'There are no V_Channels for processing\n');
    return;
end    

%--- analyse TV_ref file
TV_ref_file_name    = [RawDataFolder Stream_file_name TV_ref_file_suffix]
fTV_ref = fopen(TV_ref_file_name,'rb');
if(fTV_ref == -1)
    fprintf(1,'Can''t open %s file\n', TV_ref_file_name);
    return;
end    
fseek(fTV_ref,0,'eof');
fTV_ref_len = ftell(fTV_ref);
TV_frames_num = fTV_ref_len/TV_ref_file_line_size;
fprintf(1,'Number of TV-frames: %d\n', TV_frames_num);

if(AllFrames == 1)
    Frame_start = 1;
    Frame_num   = TV_frames_num;
end    

fseek(fTV_ref, -TV_ref_file_line_size + TV_ref_LinFrameNum_size,'eof');
I_frames_num = fread(fTV_ref,1,'uint32');
if(I_frames_num == TV_ref_IRecord_MaxVal)
    I_frames_num = 0;
else
    I_frames_num = I_frames_num + 1;
end    
fprintf(1,'Number of I-frames associated with TV-stream: %d\n', I_frames_num);

%---
if((V_Channels(1:2) == [0 1]) & (I_frames_num < (Frame_start + Frame_num - 1)))
    fprintf(1,'[ERROR] No need I-frames\n');
end    

if((V_Channels(1) == 1) && (TV_frames_num < (Frame_start + Frame_num - 1)))
    fprintf(1,'[ERROR] No need TV-frames\n');
end    

if((V_Channels(2) == 1) && (I_frames_num > 0))
    I_stream_file_name    = [RawDataFolder Stream_file_name I_stream_file_suffix];
    fI_stream = fopen(I_stream_file_name,'rb');
    if(fI_stream == -1)
        fprintf(1,'Can''t open %s file\n', I_stream_file_name);
        fclose('all');
        return;
    end
end    

%---
if(V_Channels(1:2) == [0 1])
    tic
    tb4raw_IFramesOnly;
    toc
    fclose('all');
    return;
end    

TV_stream_file_name = [RawDataFolder Stream_file_name TV_stream_file_suffix];
fTV_stream = fopen(TV_stream_file_name,'rb');
if(fTV_stream == -1)
    fprintf(1,'Can''t open %s file\n', TV_stream_file_name);
    fclose('all');
    return;
end

if((V_Channels(2) == 1) && (I_frames_num ~= 0))
    AlphaBlender = video.AlphaBlender('OpacitySource','Input port');
    I_frameRGB   = [];
    I_frameAlpha = [];
    I_FrameLastNum = TV_ref_IRecord_MaxVal;
end

if(strcmp(ZoomSource, 'from_TB4'))
    VariabledZoom = 1;
else
    VariabledZoom = 0;
end    

BaseImgFileName = [RawDataFolder Stream_file_name];

if(strcmp(VideoOutMode,'video'))
    if(VideoCompression)
        VideoFileName = sprintf('%sc.avi',BaseImgFileName);
        vidObj = VideoWriter(VideoFileName,'Motion JPEG AVI');
        vidObj.FrameRate = VideoFrameRate;
        vidObj.Quality   = VideoQuality;
    else
        if(OCTAVE)
            VideoFileName = sprintf('%snc.avi',BaseImgFileName);
            vidObj = avifile(VideoFileName,'codec','rawvideo');
            %vidObj = avifile(VideoFileName);
            aviinfo(VideoFileName)
        else
            VideoFileName = sprintf('%snc.avi',BaseImgFileName);
            vidObj = VideoWriter(VideoFileName,'Uncompressed AVI');
            vidObj.FrameRate = VideoFrameRate;
        end
    end    
    if(~OCTAVE)
        open(vidObj);
    end    
end

if(V_Channels(3))
    GenSightMark = TB4raw_GenerateSightMark(SightMarkHalfSize, SightMarkType);
end    

%---
OldPercentFrameCount = 0;
% debug
%old_srcTV_Frame = [];
% debug
tic
if(CreateRawFrameArray)
    nRawFrame = 1;
end

for nFrame = Frame_start:(Frame_start + Frame_num - 1)
    [LinFrameNum, I_FrameNum, CmdZoomFactor] = tb4raw_ReadRefRecord(fTV_ref, nFrame, TV_ref_file_line_size);
    [rawTV_Frame count] = tb4raw_ReadFrame(fTV_stream, nFrame, TV_xSize, TV_ySize, TV_PixSize);
    %rawTV_Frame = medfilt2(rawTV_Frame);
    if(CreateRawFrameArray)
        RawFrameArray{nRawFrame} = rawTV_Frame;
        nRawFrame = nRawFrame + 1;
    end    
    if(VariabledZoom)
        ZoomFactor = CmdZoomFactor + 1;
    end    
    if(UseDefaultZoomSrcClip)
        srcTV_Frame = tb4raw_ZoomDefSrcClip(rawTV_Frame, ZoomFactor, [TV_xSize TV_ySize], [I_xSize I_ySize]);
        TV_dst_originX = (I_xSize - TV_xSize)/2 + 1;
        TV_dst_originY = (I_ySize - TV_ySize)/2 + 1;
        %[TV_dst_originX, TV_dst_originY] = tb4raw_ZoomDefDstOrigin(ZoomFactor);
    else
        srcTV_Frame = rawTV_Frame(TV_src_originY:(TV_src_originY + TV_src_sizeY - 1),TV_src_originX:(TV_src_originX + TV_src_sizeX - 1));
    end
    outTV_Frame = tb4raw_Zoom(srcTV_Frame, ZoomFactor, ZoomMethod);
    [outTV_FrameSizeY, outTV_FrameSizeX] = size(outTV_Frame);
    outTV_Frame = double(outTV_Frame); % OCTAVE
    outTV_Frame = mat2gray(outTV_Frame, [0 TV_MaxValue]);         %
    
    %---
    % additional outTV_Frame processing may be placed here
    % debug
    %     if(~isempty(old_srcTV_Frame))
    %         outTV_Frame = 0.7*old_srcTV_Frame + 0.3*outTV_Frame;
    %     end
    %     old_srcTV_Frame = outTV_Frame;
    % debug
    %---
    
    if((I_frames_num == 0) || (V_Channels(2) == 0))               % no I-frames in output stream
        if(V_Channels(3))
            outTV_Frame = TB4raw_InsertSightMark(repmat(outTV_Frame, [1 1 3]), GenSightMark, SM_offsetX, SM_offsetY);
            outFrameDim = 3;
        else    
            outFrameDim = 1;
        end
        if(strcmp(VideoOutMode,'video') & (VariabledZoom == 1))      % in this case all frames must have the same size 
            outFrame = zeros(I_ySize, I_xSize, outFrameDim);
            outFrame(TV_dst_originY:(TV_dst_originY + outTV_FrameSizeY - 1), TV_dst_originX:(TV_dst_originX + outTV_FrameSizeX - 1),:) = outTV_Frame;
        else
            outFrame = outTV_Frame;
        end    
    else
        outFrame = zeros(I_ySize, I_xSize);
        outFrame(TV_dst_originY:(TV_dst_originY + outTV_FrameSizeY - 1), TV_dst_originX:(TV_dst_originX + outTV_FrameSizeX - 1)) = outTV_Frame;
        outFrame = repmat(outFrame, [1 1 3]);
        if(I_FrameLastNum ~= I_FrameNum)
            I_FrameLastNum = I_FrameNum;
            [I_Frame count] = tb4raw_ReadFrame(fI_stream, (I_FrameNum + 1), I_xSize, I_ySize, I_PixSize);
            [I_frameRGB,I_frameAlpha] =  tb4raw_GenI_frame(I_Frame);
        end
        if(~isempty(I_frameRGB))
            outFrame = step(AlphaBlender,outFrame,I_frameRGB,I_frameAlpha);
        else
            if(V_Channels(3))
                outFrame = TB4raw_InsertSightMark(outFrame, GenSightMark, SM_offsetX, SM_offsetY);
            end    
        end    
    end    
    
    if(strcmp(VideoOutMode,'video'))
        if(OCTAVE)
            try
                addframe(vidObj,outFrame);
            catch 
            end
        else
            writeVideo(vidObj,outFrame);
        end
    else
        if(OCTAVE)
            ImgFileName = sprintf('%s.Frame%03d.tiff',BaseImgFileName,nFrame); % OCTAVE
            outFrame = im2uint8(outFrame);  % OCTAVE
            imwrite(outFrame,ImgFileName); % OCTAVE
        else
            ImgFileName = sprintf('%s.Frame%03d.png',BaseImgFileName,nFrame); % MATLAB
            imwrite(outFrame,ImgFileName,'bitdepth',16); % MATLAB
            hImg = imshow(outFrame); % debug
            hPixelInfoPanel = impixelinfo(hImg);        % debug
            set(gcf,'pointer','crosshair');             % debug
            %     imfinfo('slon.png')
        end
    end
    
    PercentFrameCount = floor((nFrame - Frame_start + 1)*100/Frame_num);
    if((rem(PercentFrameCount,10) == 0) && (PercentFrameCount ~= OldPercentFrameCount))
        OldPercentFrameCount = PercentFrameCount;
        fprintf(1,'%3d%% frames processed\n',PercentFrameCount);
    end    
end
toc

%---
if(exist('vidObj'))
    close(vidObj);
end    
fclose('all');

if(CreateRawFrameArray)
    %save([BaseImgFileName '.mat'], 'RawFrameArray','-mat','-v7.3');
    save([BaseImgFileName '.mat'], 'RawFrameArray','-mat');
end    

