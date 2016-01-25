%--------------------------------------------------------------------------
%   read inflow data stream (TB-4 FPGA project)
%   and check FPGA design results
%--------------------------------------------------------------------------

%------------------------------------------
%   parameters
%
MAX_DEV_NUM = 3;                          % number of actual devices in system
INFLOW_FILE = '..\\Logs\\in_stream.txt';  % inflow file name
DEV_FILE_XX = '..\\Logs\\Dev_';       % device file name

DSF_MASK    = bitshift(1,11);                  % 800h
DevAddrs    = bitor([0:MAX_DEV_NUM-1],DSF_MASK); % 801h, 802h, 803h, ...
CheckDevs   = [0 1 1];

%------------------------------------------
fid = fopen(INFLOW_FILE,'rt');
[InflowStream, InflowSize] = fscanf(fid,'%x');
fclose(fid);

ReadDevData = repmat(struct('Data',[],'DataNum',[]),MAX_DEV_NUM,1);

clc;
fprintf(1,'Test DataStream Switch\n\n');
fprintf(1,'read from %s %d records\n\n',INFLOW_FILE, InflowSize);
for k = 1:MAX_DEV_NUM
    dev_file = [DEV_FILE_XX num2str(k-1)];
    fid = fopen(dev_file,'rt');
    if(fid == -1)
        fprintf(1,'file %s not opened\n',dev_file);
        continue;
    else
       [ReadDevData(k).Data, ReadDevData(k).DataNum] = fscanf(fid,'%x');
       fprintf(1,'read from %s %d records\n',dev_file, ReadDevData(k).DataNum);
    end    
    fclose(fid);
end    

%---------------------------
%   parsing input stream
%
DevData = repmat(struct('Data',[],'DataNum',0),MAX_DEV_NUM,1);
CurrentDevAddr = 0;
for k = 1:InflowSize
    %--- check for valid DFM
    DevAddr = find(DevAddrs == InflowStream(k));
    if(~isempty(DevAddr))
      CurrentDevAddr = DevAddr;
      continue;
    end
    %--- check for bad DFM or 'another devices addresses' DFM's
    if(bitand(InflowStream(k),DSF_MASK))
      CurrentDevAddr = 0;
      continue;
    end
    if((CurrentDevAddr <= MAX_DEV_NUM) && (CurrentDevAddr > 0))
     DevData(CurrentDevAddr).DataNum = DevData(CurrentDevAddr).DataNum + 1;
     DevData(CurrentDevAddr).Data(DevData(CurrentDevAddr).DataNum)    = InflowStream(k);
    end
end    

%---------------------------
%   compare data from model and real sources
%
fprintf(1,'\n--------- Compare results ---------\n');
error_flag = false;
for k = 1:MAX_DEV_NUM
    if(CheckDevs(k))
      if(DevData(k).DataNum ~= ReadDevData(k).DataNum)
          error_flag = true;
          fprintf(1,'Error in stream for %d device (compare 1) %d %d \n',k-1, DevData(k).DataNum, ReadDevData(k).DataNum);
%           Nm = min(DevData(k).DataNum,ReadDevData(k).DataNum);
%           for kk = 1:Nm
%             if(DevData(k).Data(kk) ~= ReadDevData(k).Data(kk))
%                 fprintf(1,'%d %d ***********************************\n',DevData(k).Data(kk), ReadDevData(k).Data(kk)); 
%             else
%                 fprintf(1,'%d %d\n',DevData(k).Data(kk), ReadDevData(k).Data(kk)); 
%             end    
%           end
%           fprintf(1,'%d\n',DevData(k).Data(end)); 
         continue;
      end
      if([DevData(k).Data]' ~= ReadDevData(k).Data)
          error_flag = true;
          fprintf(1,'Error in stream for %d device (compare 2)\n',k-1);
          continue;
      end
    end
end 

if(error_flag == false)
    fprintf(1,'\n************* ALL OK! **************\n');
end    
    
    