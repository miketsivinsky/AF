%---

BaseImgFileName = [RawDataFolder Stream_file_name];

for nFrame = Frame_start:(Frame_start + Frame_num - 1)
 [rawFrame count] = tb4raw_ReadFrame(fI_stream, nFrame, I_xSize, I_ySize, I_PixSize);
 [I_frameRGB,I_frameAlpha] =  tb4raw_GenI_frame(rawFrame);
 
 if(I_ChannelOnly_useAlpha == 1)
     I_frameRGB = I_frameRGB.*repmat(I_frameAlpha, [1 1 3]);
     ImgFileName = sprintf('%s.IFrame%03da.png',BaseImgFileName,nFrame);
 else    
     ImgFileName = sprintf('%s.IFrame%03d.png',BaseImgFileName,nFrame);
 end 
 imwrite(I_frameRGB,ImgFileName,'bitdepth',8);
 fprintf(1,'I-stream frame %03d saved to file %s\n',nFrame,ImgFileName);
end
