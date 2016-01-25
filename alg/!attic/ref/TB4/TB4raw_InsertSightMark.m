%--------------------------------------------------------------------------
function  outFrame = TB4raw_InsertSightMark(inFrame, SightMark, OffsetX, OffsetY)

sizeY = size(inFrame,1);
sizeX = size(inFrame,2);

[sizeYm, sizeXm] = size(SightMark);

X0 = (sizeX - sizeXm)/2 + 1 + OffsetX;
Y0 = (sizeY - sizeYm)/2 + 1 + OffsetY;

RangeX = [X0:(X0 + sizeXm - 1)];
RangeY = [Y0:(Y0 + sizeYm - 1)];

SightMarkWindow_Red   = inFrame(RangeY, RangeX,1);
SightMarkWindow_Green = inFrame(RangeY, RangeX,2);
SightMarkWindow_Blue  = inFrame(RangeY, RangeX,3);
IdxSightMarkWindow = (SightMark == 1);

SightMarkWindow_Red(IdxSightMarkWindow)   = 0;
SightMarkWindow_Green(IdxSightMarkWindow) = 0;
SightMarkWindow_Blue(IdxSightMarkWindow)  = 1;

outFrame = inFrame;
outFrame(RangeY, RangeX,1) = SightMarkWindow_Red;
outFrame(RangeY, RangeX,2) = SightMarkWindow_Green;
outFrame(RangeY, RangeX,3) = SightMarkWindow_Blue;