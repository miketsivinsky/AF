%--------------------------------------------------------------------------
function  LogValid = check_log(VESA_Log, ClockPeriod)

RecNum = VESA_Log(1,:);
Time   = VESA_Log(2,:);
VSYNC  = VESA_Log(3,:);
HSYNC  = VESA_Log(4,:);

%---
dRecNum = diff(RecNum);
if(~isempty(find(dRecNum ~= 1)))
    LogValid = 1;
    return;
end

%---
 dTime = diff(Time(2:end));      % because the first video_DAC_clk is "bad"
 if(~isempty(find(dTime ~= ClockPeriod)))
     LogValid = 2;
     return;
 end

%---
if(~isempty(find(VSYNC < 0)) || ~isempty(find(VSYNC > 1)))
    LogValid = 3;
    return;
end

%---
if(~isempty(find(HSYNC < 0)) || ~isempty(find(HSYNC > 1)))
    LogValid = 4;
    return;
end

LogValid = 0;

