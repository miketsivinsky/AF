%--------------------------------------------------------------------------
function  [LinFrameNum, I_FrameNum, ZoomFactor] = tb4raw_ReadRefRecord(fTV_ref, nRecord, TV_ref_file_line_size)

LinFrameNum = [];
I_FrameNum  = [];
ZoomFactor  = [];

fStatus = fseek(fTV_ref, TV_ref_file_line_size*(nRecord-1),'bof');
if(fStatus == 0)
    LinFrameNum  = fread(fTV_ref, 1, 'uint32');
    I_FrameNum   = fread(fTV_ref, 1, 'uint32');
    ZoomFactor   = fread(fTV_ref, 1, 'uint16');
end 
