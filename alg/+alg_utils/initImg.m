function [hImg, hAxes] = initImg(imgBuf, hFig, imgPos, cLim)
    hAxes = axes( ...
               'Parent',hFig, ...
               'Position',imgPos ...
              );
    hImg = image(imgBuf, ...
                       'Parent',hAxes, ...
                       'CDataMapping','scaled' ...
                );
    if(verLessThan('matlab','8.4'))
        set(hImg,'EraseMode','none');
    end
    set(hAxes, ...
               'DataAspectRatio',[1 1 1], ...
               'PlotBoxAspectRatioMode', 'auto', ... 
               'XTickLabel',[], ...
               'YTickLabel',[], ...
               'XTick',[], ...
               'YTick',[], ...
               'CLim', cLim ...
        );
end