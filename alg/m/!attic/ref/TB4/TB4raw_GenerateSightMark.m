%--------------------------------------------------------------------------
function  GenSightMark = TB4raw_GenerateSightMark(SightMarkHalfSize, SightMarkType)

XCenterBlank = 8;
YCenterBlank = 4;

SightMarkSize = SightMarkHalfSize*2;
GenSightMark = zeros(SightMarkSize);

cCrd1 = SightMarkSize/2;
cCrd2 = cCrd1 + 1;

hor_line = ones(1,SightMarkSize);
hor_line(cCrd1-XCenterBlank:cCrd2+XCenterBlank) = 0;

vert_line = ones(SightMarkSize,1);
vert_line(1:cCrd2+YCenterBlank) = 0;

GenSightMark(cCrd1,:) = [1]'*hor_line;
GenSightMark(:,cCrd1:cCrd2) = vert_line*[1 1];