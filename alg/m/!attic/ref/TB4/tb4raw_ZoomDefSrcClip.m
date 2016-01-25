%--------------------------------------------------------------------------
function  srcTV_Frame = tb4raw_ZoomDefSrcClip(rawFrame, ZoomFactor, FrameSize, outFrameSize)


outSizeX = outFrameSize(1);
outSizeY = outFrameSize(2);
SizeX    = FrameSize(1);
SizeY    = FrameSize(2);

%-------------------------------
if(ZoomFactor == 1)
    srcTV_Frame = rawFrame(1:SizeY, 1:SizeX);
    return;
end    

%-------------------------------
if(SizeX*ZoomFactor < outSizeX)
    ZSizeX = SizeX;
else
    ZSizeX = floor(outSizeX/ZoomFactor);
end    
if(rem(ZSizeX,2))
    ZSizeX = ZSizeX - 1;
end

%-------------------------------
if(SizeY*ZoomFactor < outSizeY)
    ZSizeY = SizeY;
else
    ZSizeY = floor(outSizeY/ZoomFactor);
end    
if(rem(ZSizeY,2))
    ZSizeY = ZSizeY - 1;
end    

% switch ZoomFactor
%     case 1
%         srcTV_Frame = rawFrame(1:SizeY, 1:SizeX);
%         return;
%     case 2
%         ZSizeX   = outSizeX/2;
%         ZSizeY   = outSizeY/2;
%     case 3
%         ZSizeX   = floor(outSizeX/3);
%         ZSizeY   = floor(outSizeY/3);
%     case 4
%         ZSizeX   = floor(outSizeX/4);
%         ZSizeY   = floor(outSizeY/4);
%     case 5
%         ZSizeX   = floor(outSizeX/5);
%         ZSizeY   = floor(outSizeY/5);
%     case 6
%         ZSizeX   = 132;
%         ZSizeY   = floor(outSizeY/6);
%     case 7
%         ZSizeX   = floor(outSizeX/7);
%         ZSizeY   = 84;
%     case 8
%         ZSizeX   = floor(outSizeX/8);
%         ZSizeY   = 74;
%     otherwise
%         srcTV_Frame = rawFrame(1:SizeY, 1:SizeX);
%         return;
% end    

ZOffsetX = (SizeX - ZSizeX)/2 + 1;
ZOffsetY = (SizeY - ZSizeY)/2 + 1;
srcTV_Frame = rawFrame(ZOffsetY:(ZOffsetY + ZSizeY - 1), ZOffsetX:(ZOffsetX + ZSizeX - 1));

