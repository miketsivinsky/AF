function [sX, eX, sY, eY] = getCenterZoneCrd(frameSizeX, frameSizeY, zoneSizeX, zoneSizeY)
    zoneSizeX2 = zoneSizeX/2;
    offsetX = frameSizeX/2 - zoneSizeX2;
    sX = offsetX + 1;
    eX = sX + zoneSizeX - 1;

    zoneSizeY2 = zoneSizeY/2;
    offsetY = frameSizeY/2 - zoneSizeY2;
    sY = offsetY + 1;
    eY = sY + zoneSizeY - 1;
end

