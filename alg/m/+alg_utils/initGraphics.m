%--------------------------------------------------------------------------
function [hImg, hAxes, colorMap] = initGraphics(imgBuf)
    import alg_utils.*;
    
    BgFigColor = [0.5 0.5 0.5];
    maxGrayValue = double(intmax('uint8'));
    imgPos = [0.0 0.0 1.0 1.0];
    %cImgLim = [0 maxGrayValue];
    cImgLim = [0 1023];
    colorSlice = (0:maxGrayValue)/maxGrayValue;
    colorMap = [colorSlice; colorSlice; colorSlice]';

    [hFig] = initFig('slon',BgFigColor,colorMap);
    [hImg, hAxes] = initImg(imgBuf, hFig, imgPos, cImgLim);
    
    drawnow;
end
