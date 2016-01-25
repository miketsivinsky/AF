%--------------------------------------------------------------------------
function [fileNum] = saveDataFile(rawBuf,lensControlValue,fileNum,outDir)
    fileName = sprintf('%sframe[%03d][%+05d].dat',outDir,fileNum,lensControlValue);
    file = fopen(fileName,'wb');
    fwrite(file,fileNum,'int32');
    fwrite(file,lensControlValue,'int32');
    fwrite(file,rawBuf,'uint16');
    fclose(file);
    fileNum = fileNum + 1;
end
    
