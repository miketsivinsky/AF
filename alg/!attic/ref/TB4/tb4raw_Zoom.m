%--------------------------------------------------------------------------
function outFrame = tb4raw_Zoom(srcFrame, ZoomFactor,ZoomMethod)

if(ZoomFactor == 1)
    outFrame = srcFrame;
else
    if(strcmp(ZoomMethod, 'TB4_ZoomMethod'))
        outFrame = tb4raw_tb4Zoom(srcFrame, ZoomFactor);
    else    
        outFrame = imresize(srcFrame, ZoomFactor, ZoomMethod);
    end    
end

%---
function outFrame = tb4raw_tb4Zoom(srcFrame, ZoomFactor)
srcFrame = double(srcFrame);
[N, M] = size(srcFrame);
RZ = tb4raw_ZoomMatrix(M, ZoomFactor);
LZ = tb4raw_ZoomMatrix(N, ZoomFactor)';

size(RZ);
size(LZ);
size(srcFrame);
outFrame = LZ*srcFrame*RZ;

%---
function Z = tb4raw_ZoomMatrix(Size, Zoom)

Size2 = Size*Zoom;
Z = zeros(Size,Size2);
v1 = ones(Zoom,1)*[1:Size];
v1 = reshape(v1, 1, Size2);
v2 = [1:Size2];
LI = sub2ind(size(Z),v1,v2);
Z(LI) = 1;
