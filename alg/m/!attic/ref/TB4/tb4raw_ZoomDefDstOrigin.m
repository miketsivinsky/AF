%--------------------------------------------------------------------------
function  [TV_dst_originX, TV_dst_originY] = tb4raw_ZoomDefDstOrigin(ZoomFactor)


switch ZoomFactor
    case 1
        TV_dst_originX = 80;
        TV_dst_originY = 60;
    case 2
        TV_dst_originX = 0;
        TV_dst_originY = 0;
    case 3
        TV_dst_originX = 1;
        TV_dst_originY = 0;
    case 4
        TV_dst_originX = 0;
        TV_dst_originY = 0;
    case 5
        TV_dst_originX = 0;
        TV_dst_originY = 0;
    case 6
        TV_dst_originX = 4;
        TV_dst_originY = 0;
    case 7
        TV_dst_originX = 1;
        TV_dst_originY = 6;
    case 8
        TV_dst_originX = 0;
        TV_dst_originY = 4;
    otherwise
        TV_dst_originX = 0;
        TV_dst_originY = 0;
end    

TV_dst_originX = TV_dst_originX + 1;
TV_dst_originY = TV_dst_originY + 1;
