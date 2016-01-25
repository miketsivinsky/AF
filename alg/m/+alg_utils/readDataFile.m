%--------------------------------------------------------------------------
function [status, frame, lensControl] = readDataFile(fileName,xSize,ySize)
    HeaderLen = 10;
    status = -1;
    frame = [];
    lensControl = [];
    file = fopen(fileName,'rb');
    if(file == -1)
        fclose('all');
        return;
    end    
    header = fread(file,HeaderLen,'int32');
    if((header(9) ~= ySize) || (header(10) ~= xSize))
        fclose(file);
        return;
    end    
    lensControl = header(2);
    frame = fread(file,[xSize,ySize],'*uint16');
    frame = frame';
    status = 1;
    fclose(file);
end

