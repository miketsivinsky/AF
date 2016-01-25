function algLogView
    
    %---
    FileDir  = 'E:/projects/OESD/A/data/out/';
    FileName = 'afData[01]';
    DataSet  = 2;
    
    
    %---
    data = load([FileDir FileName]);
    xFocusVecLen = numel(data.xFocusVec);
    dataSetNum = size(data.focusFuncBuf,1);
    fprintf(1,'\n');
    fprintf(1,'FileNum:    %3d\n',data.fileNum);  
    fprintf(1,'DataSetNum: %3d\n',dataSetNum);
    
    plot(data.xFocusVec,data.focusFuncBuf(DataSet,:),'b');
    grid;
end