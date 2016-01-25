function [hLines] = plotBorder(hAxes,x0,y0,sizeX,sizeY,color,hLines)
    %---
    x1 = x0 + sizeX - 1;
    y1 = y0 + sizeY - 1;

    %---
    lineLeftX  = ones(1,sizeY)*x0;
    lineLeftY  = y0:y1;
    %---
    lineRightX = ones(1,sizeY)*x1;
    lineRightY = y0:y1;
    %---
    lineTopX    = x0:x1;
    lineTopY    = ones(1,sizeX)*y0;
    %---
    lineBottomX = x0:x1;
    lineBottomY = ones(1,sizeX)*y1;

    %---
    if(isempty(hLines))
        hLines = zeros(1,4);
        hold(hAxes,'on');
        hLines(1) = plot(hAxes,lineLeftX,lineLeftY,color);
        hLines(2) = plot(hAxes,lineBottomX,lineBottomY,color);
        hLines(3) = plot(hAxes,lineRightX,lineRightY,color);
        hLines(4) = plot(hAxes,lineTopX,lineTopY,color);
    else
        set(hLines(1),'XData',lineLeftX,'YData',lineLeftY);
        set(hLines(2),'XData',lineBottomX,'YData',lineBottomY);
        set(hLines(3),'XData',lineRightX,'YData',lineRightY);
        set(hLines(4),'XData',lineTopX,'YData',lineTopY);
    end    
end

