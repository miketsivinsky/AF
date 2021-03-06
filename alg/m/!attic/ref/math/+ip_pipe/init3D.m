function [h3D] = init3D(z, hFig, imgPos, cLim, zLim)
    hAxes = axes( ...
                 'Parent',hFig, ...
                 'OuterPosition',imgPos, ...
                 'ZLim', zLim ...
                );
          
    N = size(z,1);
    x = 0:N-1;
    y = 0:N-1;
    [xx,yy] = meshgrid(x,y);
    h3D = mesh(hAxes,xx,yy,cast(z,'double'),'CDataMapping','scaled','VertexNormals',[]);
    %set(h3D,'EdgeColor','none');
    if(verLessThan('matlab','8.4'))
    %    set(hImg,'EraseMode','none');
    end
    set(hAxes, ...
               'XLim',[0 N-1], ...
               'YLim',[0 N-1], ...
               'ZLim',zLim, ...
               'CLim',cLim ...
        );
    xlabel(hAxes,'x','FontSize',12);
    ylabel(hAxes,'y','FontSize',12);

end