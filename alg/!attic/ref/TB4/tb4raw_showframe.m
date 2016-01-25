clear all;
tb4raw_data;
clc;

%Stream_file_name = RawData_Academ_03;
Stream_file_name = RawData_07_04_2011_06;

BaseImgFileName = [RawDataFolder Stream_file_name];
load([BaseImgFileName '.mat'], 'RawFrameArray');
TImg = double(RawFrameArray{1});
clearvars -except TImg;

hImg = tvp_show_frame_f('slon', TImg, [0 1023]);