function [ROI,nROI] = afGenVecROI(sizeFrame, sizeROI, offset)
    X = floor((sizeFrame(1) - offset(1))/sizeROI);
    Y = floor((sizeFrame(2) - offset(2))/sizeROI);
    baseROI = [  1   1 sizeROI sizeROI];
    idx = 1;
    nROI = X*Y;
    ROI = zeros(nROI,4);
    for y = 0:(Y-1)
        for x = 0:(X-1)
            ROI(idx,:) = baseROI + [x*sizeROI y*sizeROI 0 0];
            idx = idx + 1;
        end    
    end    
    ROI(:,1) = ROI(:,1) + offset(1);
    ROI(:,2) = ROI(:,2) + offset(2);
end