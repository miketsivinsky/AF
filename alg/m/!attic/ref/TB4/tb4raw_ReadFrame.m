%--------------------------------------------------------------------------
function  [rawFrame,count] = tb4raw_ReadFrame(fData, nFrame, Xsize, Ysize, pixSize)

%--- 
count = 0;
switch pixSize
    case 1
        DataType = 'uint8';
    case 2    
        DataType = 'uint16';
    case 4    
        DataType = 'uint32';
    otherwise    
        rawFrame = [];
        return;
end    
fStatus = fseek(fData, Xsize*Ysize*pixSize*(nFrame-1),'bof');
if(fStatus ~= 0)
    rawFrame = [];
else
    [rawFrame, count]  = fread(fData,[Xsize, Ysize],[DataType '=>' DataType]);
    %[rawFrame, count]  = fread(fData,[Xsize, Ysize],DataType);
    %class(rawFrame)
end 

if(count ~= (Xsize*Ysize))
    rawFrame = [];
    return;
end    

rawFrame = rawFrame';
