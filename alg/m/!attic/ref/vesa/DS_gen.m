%--------------------------------------------------------------------------
%   Generate inflow data stream (TB-4 FPGA project)
%--------------------------------------------------------------------------

clear classes;
clc;

%------------------------------------------
%   parameters
%
STREAM_NUM          = 2;

USE_WORK_FRAME_SIZE = 0;
STREAM_LENGTH       = 10000;
if(STREAM_NUM == 2)
    STREAM_SHEDULE      = [2000 1];
else
    STREAM_SHEDULE      = [1000 0 1];
end    

%--- Stream 1: Thermovision Camera
TV_DEV_ADDR     = 1;
if(USE_WORK_FRAME_SIZE)
    TV_FRAME_X_SIZE = 640;
    TV_FRAME_Y_SIZE = 480;
else
    TV_FRAME_X_SIZE = 30;
    TV_FRAME_Y_SIZE = 20;
end    

%--- Stream 2: Information Stream
I_DEV_ADDR      = 2;
if(USE_WORK_FRAME_SIZE)
    I_FRAME_X_SIZE  = 800;
    I_FRAME_Y_SIZE  = 600;
else
    I_FRAME_X_SIZE  = 40;
    I_FRAME_Y_SIZE  = 30;
end    

if(STREAM_NUM ==3)
    C_DEV_ADDR      = 0;
end    
    

STREAM_FILE = '..\\Logs\\in_stream.txt';  % inflow file name

%------------------------------------------
TV_GEN  = TVideoGenNSeq(TV_DEV_ADDR,TV_FRAME_Y_SIZE,TV_FRAME_X_SIZE,10);
I_GEN   = TVideoGenNSeq(I_DEV_ADDR,I_FRAME_Y_SIZE,I_FRAME_X_SIZE,8);
if(STREAM_NUM ==3)
   % C_GEN  = TVideoGenNSeq(C_DEV_ADDR,3,4,8);
   C_GEN   =  TVideoGenConst(C_DEV_ADDR,3,4,8,0);
end    

if(STREAM_NUM == 2)
    SG = {TV_GEN I_GEN};
else
    SG = {TV_GEN I_GEN C_GEN };
end    

StreamNum    = 0;
SwitchStream = 1;

fid = fopen(STREAM_FILE,'wt');

for k = 1:STREAM_LENGTH
    if(SwitchStream)
        SwitchStream = 0;
        StreamNum    = StreamNum + 1;
        if(StreamNum > STREAM_NUM)
            StreamNum = 1;
        end
        StreamCounter = STREAM_SHEDULE(StreamNum);
        
        Data = SG{StreamNum}.GetDevAddr;
    else
        [SG{StreamNum}, Data] = SG{StreamNum}.GetNextData;
        StreamCounter = StreamCounter - 1;
        if(StreamCounter <= 0)
            SwitchStream = 1;
        end    
    end
    %dec2hex(Data)
    fprintf(fid,'%03x\n',Data);
end

fclose(fid);
