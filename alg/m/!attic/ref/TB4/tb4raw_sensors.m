%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
RawDataFolder = DATA_DIR;

for JobNum=1:JobListSize
    Stream_file_name = char(JobList(JobNum));
    
    %ImgSource   = 'TB4';   % TB4, IFP or TVC
    
    V_Channels  = [1 0 0]; % TV-stream, I-stream, Generated Sight Mark
    Frame_start = 1;       % numeration from 1
    Frame_num   = 20;     % num ber of frames
    AllFrames   = 1;       %
    
    %---
    VideoOutMode          = 'video';    % video or split frames outputs
    VideoCompression      = 0;
    VideoQuality          = 100;
    VideoFrameRate        = 25;
    
    %---
    ZoomSource            = 'no_from_TB4'; % from TB or from ZoomFactor
    ZoomFactor            = 1;          % ignored if ZoomSource == 'from_TB4'
    
    %ZoomMethod             = 'TB4_ZoomMethod';
    %ZoomMethod            = 'nearest';
    ZoomMethod            = 'bilinear';
    %ZoomMethod            = 'bicubic';
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
    CreateRawFrameArray = 1; 
    
    %---
    tb4raw
end    
