%--------------------------------------------------------------------------
function  [start_idx, len, HSync_valid, VSync_valid, Valid] = check_signals( ...
                                          VSYNC, ...
                                          V_PERIOD, ...
                                          V_SYNC_WIDTH, ...
                                          HSYNC, ...
                                          H_PERIOD, ...
                                          H_SYNC_WIDTH ...
                                          )

start_idx   = 1;
len         = numel(HSYNC);
HSync_valid = 0;
VSync_valid = 0;
Valid       = 0;

%--- find the first 0 in HSYNC: this is 'start of non-analysing sequence'
H_first_0 = find(HSYNC == 0,1);
if(isempty(H_first_0))
    HSync_valid = 1;
    Valid = 1;
    return;
end

%--- remove elements before the first non-analysing data
HSYNC = HSYNC(H_first_0:end);
VSYNC = VSYNC(H_first_0:end);

%--- find the first 1 in HSYNC: this is 'start of analysing sequence'
H_first_1 = find(HSYNC == 1,1);
if(isempty(H_first_1))
    HSync_valid = 2;
    Valid = 1;
    return;
end

%--- remove elements before the first analysing data
HSYNC = HSYNC(H_first_1:end);
VSYNC = VSYNC(H_first_1:end);

%--- compute full periods for H and V
HSYNC_full_periods = floor(numel(HSYNC)/H_PERIOD); 
VSYNC_full_periods = floor(numel(VSYNC)/(V_PERIOD*H_PERIOD));

%--- not less than one full frame
if(VSYNC_full_periods < 1)
    VSync_valid = 1;
    Valid = 1;
    return;
end

%--- obsolete ?
if(HSYNC_full_periods < 1)
    HSync_valid = 3;
    Valid = 1;
    return;
end    

%--- calculate the new start idx
start_idx = H_first_0 + H_first_1 - 1;

%--- calculate length of data
len       = VSYNC_full_periods*V_PERIOD*H_PERIOD;

HSYNC_full_periods = len/H_PERIOD;

HSYNC = HSYNC(1:len);
VSYNC = VSYNC(1:len);

%--- total control of HSYNC (alone, independently of VSYNC)
HSYNC = reshape(HSYNC, H_PERIOD, HSYNC_full_periods)';
HSYNC_check_pattern = zeros(1,H_PERIOD);
HSYNC_check_pattern(1:H_SYNC_WIDTH) = 1;

hError = 0;
for k = 1:HSYNC_full_periods
    if(sum(HSYNC(k,:) ~= HSYNC_check_pattern))
        hError = hError + 1;
        fprintf(1,'HSYNC error in %d HSYNC\n',k);
    end    
end    
if(hError)
    HSync_valid = 4;
    Valid = 1;
    return;
end    

%--- total control of VSYNC (alone, independently of HSYNC)
VSYNC = reshape(VSYNC, V_PERIOD*H_PERIOD, VSYNC_full_periods)';
VSYNC_check_pattern = zeros(1,V_PERIOD*H_PERIOD);
VSYNC_check_pattern(1:V_SYNC_WIDTH*H_PERIOD) = 1;

vError = 0;
for k = 1:VSYNC_full_periods
    if(sum(VSYNC(k,:) ~= VSYNC_check_pattern))
        vError = vError + 1;
        fprintf(1,'VSYNC error in %d VSYNC\n',k);
    end    
end    
if(vError)
    VSync_valid = 2;
    Valid = 1;
    return;
end    

%--- HSYNC and VSYNC relative sequence positions we control 'automatically'
%    because we 'synchronize' data in HSYNC and VSYNC arrays above
