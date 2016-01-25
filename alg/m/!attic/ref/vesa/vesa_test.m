%--------------------------------------------------------------------------
% VESA test
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% settings
%--------------------------------------------------------------------------

VESA_800_600_60Hz = 0;
ShowFrameNum      = 18;

VESA_LogName = '../Logs/vesa.log';
ClockPeriod  = 25;  % ns
TimeScale    = 0.1; % 100 ps

if(VESA_800_600_60Hz)
    % Horizontal settings
    H_PERIOD        = 1056; % Hor Total Time (in VESA standard termins)
    H_SYNC_WIDTH    = 128;  % Hor Sync Time
    H_VIDEO_START   = 88;   % H Back Porch + H Left Border
    H_VIDEO_WIDTH   = 800;  % Hor Addr Time
    H_SYNC_POLARITY = 1;    % Hor Sync Polarity, 1 - positive, 0 - negative

    TV_FRAME_X_ORIGIN  = 80;
    TV_FRAME_X_SIZE    = 640;
    
    % Vertical settings
    V_PERIOD        =  628; % Ver Total1Time (in VESA standard termins)
    V_SYNC_WIDTH    =  4;   % Ver Sync Time
    V_VIDEO_START   =  23;  % V Back Porch + H Top Border
    V_VIDEO_WIDTH   =  600; % Ver Addr Time
    V_SYNC_POLARITY =  1;   % Ver Sync Polarity, 1 - positive, 0 - negative

    TV_FRAME_Y_ORIGIN  = 60;
    TV_FRAME_Y_SIZE    = 480;
else
    % Horizontal settings
    H_PERIOD        = 60;   % Hor Total Time (in VESA standard termins)
    H_SYNC_WIDTH    = 4;    % Hor Sync Time
    H_VIDEO_START   = 10;   % H Back Porch + H Left Border
    H_VIDEO_WIDTH   = 40;   % Hor Addr Time
    H_SYNC_POLARITY = 1;    % Hor Sync Polarity, 1 - positive, 0 - negative

    TV_FRAME_X_ORIGIN  = 4;
    TV_FRAME_X_SIZE    = 30;

    % Vertical settings
    V_PERIOD        =  40;  % Ver Total Time (in VESA standard termins)
    V_SYNC_WIDTH    =  2;   % Ver Sync Time
    V_VIDEO_START   =  2;   % V Back Porch + H Top Border
    V_VIDEO_WIDTH   =  30;  % Ver Addr Time
    V_SYNC_POLARITY =  1;   % Ver Sync Polarity, 1 - positive, 0 - negative

    TV_FRAME_Y_ORIGIN  = 3;
    TV_FRAME_Y_SIZE    = 20;
end    
%--------------------------------------------------------------------------
clc;

fid = fopen(VESA_LogName,'rt');
[VESA_Log,Nrecords] = fscanf(fid,'%u %u %u %u %u %u %u',[7,inf]);
fclose(fid);

fprintf(1,'Read %d records from VESA log (file: %s)\n',size(VESA_Log,2), VESA_LogName);

%-----------------------
LogIntegrity = check_log(VESA_Log, ClockPeriod/TimeScale);
if(LogIntegrity)
    fprintf(1,'Log integrity: Error (code: %d)\n',LogIntegrity);
    return;
else
    fprintf(1,'Log integrity: OK\n');
end    

RecNum = VESA_Log(1,:);
Time   = VESA_Log(2,:);
VSYNC  = VESA_Log(3,:);
HSYNC  = VESA_Log(4,:);
ImgDataRGB = VESA_Log(5:7,:);

% 'normalize' sync polarity to 'positive'
VSYNC = bitxor(VSYNC, ~V_SYNC_POLARITY);
HSYNC = bitxor(HSYNC, ~H_SYNC_POLARITY);

Time = Time*TimeScale;

%-----------------------
[start_idx, len,  HSync_valid, VSync_valid, Valid] = check_signals(...
                                                                VSYNC, ...
                                                                V_PERIOD, ...
                                                                V_SYNC_WIDTH, ...
                                                                HSYNC, ...
                                                                H_PERIOD, ...
                                                                H_SYNC_WIDTH ...
                                                            );
if(Valid)
    fprintf(1,'Signal analysing: Error (H: %d, V: %d)\n',HSync_valid, VSync_valid);
    return;
else
    fprintf(1,'Signal analysing: OK\n');
end   

%-----------------------
HSYNC  = HSYNC(start_idx : start_idx+len-1);
VSYNC  = VSYNC(start_idx : start_idx+len-1);
RecNum = RecNum(start_idx : start_idx+len-1);
Time   = Time(start_idx : start_idx+len-1);
ImgDataRGB = ImgDataRGB(:,start_idx : start_idx+len-1);

FrameNum = len/(V_PERIOD*H_PERIOD);
fprintf(1,'In current log %d full frames\n',FrameNum);
if(ShowFrameNum > FrameNum)
    ShowFrameNum = 1;
end    

ImgDataRGB_frames = reshape(ImgDataRGB, 3, H_PERIOD, V_PERIOD, FrameNum);
ImgDataRGB_frames = permute(ImgDataRGB_frames,[3 2 1 4]);

HSYNC_frames = reshape(HSYNC, H_PERIOD, V_PERIOD, FrameNum);
HSYNC_frames = permute(HSYNC_frames,[2 1 3]);

VSYNC_frames = reshape(VSYNC, H_PERIOD, V_PERIOD, FrameNum);
VSYNC_frames = permute(VSYNC_frames,[2 1 3]);

FrameRGB = make_rgb_frame(VSYNC_frames(:,:,1), HSYNC_frames(:,:,1), ImgDataRGB_frames(:,:,:,ShowFrameNum));
FrameRGB(1,1,:) = 40000;
%FrameRGB(628,1,:) = 40000;

Img_X0 = H_SYNC_WIDTH + H_VIDEO_START + 1;
Img_X1 = Img_X0 + H_VIDEO_WIDTH - 1;
Img_Y0 = V_SYNC_WIDTH + V_VIDEO_START + 1;
Img_Y1 = Img_Y0 + V_VIDEO_WIDTH - 1;

ImgTV_X0 = Img_X0 + TV_FRAME_X_ORIGIN;
ImgTV_X1 = ImgTV_X0 + TV_FRAME_X_SIZE - 1;
ImgTV_Y0 = Img_Y0 + TV_FRAME_Y_ORIGIN;
ImgTV_Y1 = ImgTV_Y0 + TV_FRAME_Y_SIZE - 1;

% FrameRGB(Img_Y0,Img_X0,:) = 60000;
% FrameRGB(Img_Y0,Img_X1,:) = 60000;
% FrameRGB(Img_Y1,Img_X0,:) = 60000;
% FrameRGB(Img_Y1,Img_X1,:) = 60000;

if(VESA_800_600_60Hz)
    Magnification = 100';
    ImgTitle      = 'VESA frame';
else
    Magnification = 'fit';
    ImgTitle      = 'Test frame';
end    
[hAxesFrame] = vesa_show(FrameRGB, ImgTitle, Magnification);


plot_fborder(hAxesFrame,Img_X0,Img_Y0,Img_X1,Img_Y1,'r');

plot_fborder(hAxesFrame,Img_X0-0.5,Img_Y0-0.5,Img_X0+0.5,Img_Y0+0.5,'w');
plot_fborder(hAxesFrame,Img_X1-0.5,Img_Y0-0.5,Img_X1+0.5,Img_Y0+0.5,'w');
plot_fborder(hAxesFrame,Img_X0-0.5,Img_Y1-0.5,Img_X0+0.5,Img_Y1+0.5,'w');
plot_fborder(hAxesFrame,Img_X1-0.5,Img_Y1-0.5,Img_X1+0.5,Img_Y1+0.5,'w');

plot_fborder(hAxesFrame,ImgTV_X0,ImgTV_Y0,ImgTV_X1,ImgTV_Y1,'g');

%--------------------------------------------------------------------------
% Movie = uint16(zeros([size(FrameRGB) 10]));
% Movie(:,:,:,1) = FrameRGB;
% Movie(:,:,:,2) = FrameRGB/2;
% Movie(:,:,:,3) = FrameRGB/3;
% 
% implay(Movie);
