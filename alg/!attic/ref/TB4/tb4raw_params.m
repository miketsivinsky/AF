%--------------------------------------------------------------------------
%--- changed params
%
%    for IFP device the following parameters must/should/can be changed
%
%    must:   TV_xSize            - from 640 to 320    
%    must:   TV_ySize            - from 480 to 240    
%    should: VideoFrameRate      - from 25 to 30
%    can:    CreateRawFrameArray - from 0 to 1
%--------------------------------------------------------------------------
clear all;
tb4raw_data;
clc;
tStart = tic;
JobListSize = size(JobList,1);
JobListSize = 1;

OCTAVE = 0;

for JobNum=1:JobListSize
    %Stream_file_name = char(JobList(JobNum));
    %Stream_file_name = RawData_IFP_test;
    %Stream_file_name = POOS2_4;

    %Stream_file_name = RawData_Academ_03;     % frame 1200 
    %Stream_file_name = RawData_07_04_2011_06;  % frame 200
    %Stream_file_name = TB4_04_50123007_cold;
    %Stream_file_name = TB4_04_50123007_warm;
    %Stream_file_name = TB4_04_50123007_test;
    %Stream_file_name = TB4_05_50124006_cold;
    %Stream_file_name = TB4_05_50124006_warm;
    
    %Stream_file_name = TB4_06_50124007_cold;
    %Stream_file_name = TB4_06_50124007_warm;
    %Stream_file_name = TB4_06_50124007_test;
    
    %Stream_file_name = TB4_07_50117017_cold;
    %Stream_file_name = TB4_07_50117017_warm;
    %Stream_file_name = TB4_07_50117017_test;

    Stream_file_name = RawData_Range_Sight1_700m;
    
    ImgSource   = 'TB4';   % TB4, IFP or TVC
    
    V_Channels  = [1 0 0]; % TV-stream, I-stream, Generated Sight Mark
    Frame_start = 2730;       % numeration from 1
    Frame_num   = 1;      % number of frames
    AllFrames   = 0;       %
    
    %---
    VideoOutMode          = 'no_video';    % video or split frames outputs
    VideoCompression      = 0;
    VideoQuality          = 100;
    VideoFrameRate        = 25;
    
    %---
    ZoomSource            = 'not_from_TB4'; % from TB or from ZoomFactor
    ZoomFactor            = 12;             % ignored if ZoomSource == 'from_TB4'
    
    %ZoomMethod             = 'TB4_ZoomMethod';
    %ZoomMethod            = 'nearest';
    %ZoomMethod            = 'bilinear';
    ZoomMethod            = 'bicubic';
    %ZoomMethod            = 'lanczos2';
    %ZoomMethod            = 'lanczos3';
    
    
    UseDefaultZoomSrcClip = 1; % when '1' than clipping from Src TV frame
    % used with automatically (default) calculated
    % X/Y src origin, X/Y src subframe size and
    % X/Y dst origin
    %---
    SightMarkHalfSize = 40;
    SightMarkType     = 1;
    
    %---
    TV_src_originX = 311;
    TV_src_originY = 215;
    
    TV_src_sizeX   = 40;
    TV_src_sizeY   = 30;
    
    TV_dst_originX = 600;
    TV_dst_originY = 400;
    
    I_ChannelOnly_useAlpha = 0; % used only when V_Channels  == [0 1]
    % I_ChannelOnly_useAlpha == 0 - output image
    % not uses alpha-channel
    % I_ChannelOnly_useAlpha == 1 - output image
    % uses alpha-channel (suppose there is virtual
    % BG black image)
    
    SM_offsetX     = 0;
    SM_offsetY     = 100;
    
    %--------------------------------------------------------------------------
    %--- not changed params
    %--------------------------------------------------------------------------
    Info_file_suffix        = '.info';
    Idx_file_suffix         = '.idx';
    TV_ref_file_suffix      = '.tv_ref';
    
    CMD_stream_file_suffix  = '.s00';
    TV_stream_file_suffix   = '.s01';
    I_stream_file_suffix    = '.s02';
    
    %--- TV_ref file params
    TV_ref_LinFrameNum_size = 4;
    TV_ref_IRecord_size     = 4;
    TV_ref_CurrZoom_size    = 2;
    
    TV_ref_file_line_size   = TV_ref_LinFrameNum_size + TV_ref_IRecord_size + TV_ref_CurrZoom_size;
    TV_ref_IRecord_MaxVal   = intmax('uint32');
    
    %--- TV stream params
    switch ImgSource
        case 'TB4'
            TV_xSize    = 640;
            TV_ySize    = 480;
        case 'IFP'
            TV_xSize    = 320;
            TV_ySize    = 240;
        case 'TVC'
            TV_xSize    = 752;
            TV_ySize    = 582;
        otherwise
            TV_xSize    = 640;
            TV_ySize    = 480;
    end    
    
    TV_PixSize  = 2;
    TV_MaxValue = 1023;
    
    %--- I stream params
    I_xSize    = 800;
    I_ySize    = 600;
    I_PixSize  = 2;

    %---
    CreateRawFrameArray = 0; 
    
    %---
    tb4raw
end    
toc(tStart)