clear classes;

%---
RawDataFolder                = 'E:\TB4 RawData\';

%---
RawData_Range_Sight1_300m    = 'Дальность (05-10-2010)\Прицел 1 (целая оптика)\300\05-10-2010 11-28-38.tb4';
RawData_Range_Sight1_400m    = 'Дальность (05-10-2010)\Прицел 1 (целая оптика)\400\05-10-2010 11-33-58.tb4';
RawData_Range_Sight1_500m    = 'Дальность (05-10-2010)\Прицел 1 (целая оптика)\500\05-10-2010 11-39-29.tb4';
RawData_Range_Sight1_700m    = 'Дальность (05-10-2010)\Прицел 1 (целая оптика)\700\05-10-2010 11-49-56.tb4';
RawData_Range_Sight1_800m02  = 'Дальность (05-10-2010)\Прицел 1 (целая оптика)\800\02\05-10-2010 12-42-57.tb4';
RawData_Range_Sight1_1000m   = 'Дальность (05-10-2010)\Прицел 1 (целая оптика)\1000\05-10-2010 12-05-57.tb4';

%---
RawData_Polygon_Sight2_17    = 'Полигон (06-10-2010)\Прицел 2 (облезлая оптика)\17\06-10-2010 14-46-27.tb4';

%---
RawData_Academ_03            = 'Академгородок (вечер дождь)\03\07-10-2010 20-44-16.tb4';

%---
CMD_stream_file_suffix  = '.s00';
TV_stream_file_suffix   = '.s01';
I_stream_file_suffix    = '.s02';

TV_stream_file_name = RawData_Range_Sight1_300m;
TV_stream_file_name = [RawDataFolder  TV_stream_file_name TV_stream_file_suffix]
TV_FrameNum = 0;
ZoomFactor  = 8;

TV_xSize    = 640;
TV_ySize    = 480;
TV_PixSize  = 2;

TV_FrameSize = TV_xSize*TV_ySize;

fid = fopen(TV_stream_file_name,'rb');
fseek(fid,0,'eof');
flen = ftell(fid);
total_frames = flen/(TV_FrameSize*TV_PixSize);
fprintf(1,'Total frames %d\n',total_frames);

aviobj = avifile('slon_a3v.avi','compression','none','fps',25);
cmap = [0:255]'*ones(1,3)/255;

ff = 60;
for f=0:(ff-1)
    status = fseek(fid,(TV_FrameNum + f)*TV_FrameSize*TV_PixSize,'bof');
    if(status ~= 0)
        status
        return;
    end
    [TV_frame, count]  = fread(fid,[TV_xSize, TV_ySize],'uint16');
    TV_frame = TV_frame';
    ss = im2frame((TV_frame/4 + 1),cmap);
    aviobj = addframe(aviobj,ss);
    if( rem((f+1),25) == 0)
        (f+1)/25
    end    
end

aviobj = close(aviobj);
fclose(fid);


%---
figure;
hImg = imshow(TV_frame, [min(TV_frame(:)) max(TV_frame(:))]);
%hImg = imshow(TV_frame,[0 1023]);
hPixelInfoPanel = impixelinfo(hImg);
hDrangePanel = imdisplayrange(hImg);
title('original image');
set(gcf,'pointer','crosshair');


return;

%---
TV_frameXn = imresize(TV_frame, ZoomFactor, 'nearest');
figure;
hImg = imshow(TV_frameXn, [min(TV_frameXn(:)) max(TV_frameXn(:))]);
hPixelInfoPanel = impixelinfo(hImg);
hDrangePanel = imdisplayrange(hImg);
title('zoom (nearest) image');
set(gcf,'pointer','crosshair');

%---
TV_frameXbl = imresize(TV_frame, ZoomFactor, 'bilinear');
figure;
hImg = imshow(TV_frameXbl, [min(TV_frameXbl(:)) max(TV_frameXbl(:))]);
hPixelInfoPanel = impixelinfo(hImg);
hDrangePanel = imdisplayrange(hImg);
title('zoom (bilinear) image');
set(gcf,'pointer','crosshair');

%---
TV_frameXbc = imresize(TV_frame, ZoomFactor, 'bicubic');
figure;
hImg = imshow(TV_frameXbc, [min(TV_frameXbc(:)) max(TV_frameXbc(:))]);
hPixelInfoPanel = impixelinfo(hImg);
hDrangePanel = imdisplayrange(hImg);
title('zoom (bicubic) image');
set(gcf,'pointer','crosshair');

