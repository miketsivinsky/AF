%--------------------------------------------------------------------------
function guiSlon(varargin)
    clc;
    close all;
    clear all;
    
    path(path,'..\sw64\ip_pipe\src\math\');
    import ip_pipe.*
    import alg_utils.*;
    
    %---
    VideoPipeEna     = 1;
    CmdPipeGblEna    = 1;
    TestDelay        = 0.05;
    VideoPrintFactor = 100000;

    %---
    LensSetupTime         = 4;     % number of frames between "lens cmd complete" and "calculate focus func"
    AvgFrameNum           = 2;
    MaxFocusPassNum       = 1;     % number of scan pass
    FindMaxFocusIdxOffset = 3;
    ROI                   = [340 340 256]; % X0, Y0, ROI size
    FuncFocusGraphHold    = 1;
    PlotProfileAsStem     = 0;
    AlgList               = [ ... 
                               'TENG'; 'TENV'; 'VOLA'; ...
                               'GDER'; 'GLLV'; ...
                               'BREN'; 'GRAE'; 'GRAT'; 'GRAS'; 'LAPE'; 'LAPM'; 'LAPD'; 'SFRQ'; ...
                               'WAVS'; 'WAVV'; ...
                               'GLVA'; ...
                               '@LOG'; ...
                            ];
    MaxFuncFocus          = 0;      % max expected value of focus functional (used for graphics only)
    MinFuncFocus          = 0;      % min expected value of focus functional (used for graphics only)
    XFocusStartScanValue  = -200;   % left focus margin of scanned zone
    XFocusStopScanValue   = 600;    % right focus margin of scanned zone
    XFocusStep            = 10;     % focus scan step 
    XFocusInitValue       = 0;      % xFocus value after start this program (comman sent to LC)
    XFocusMinValue        = -500;
    XFocusMaxValue        = 800;
    ResultFileDir         = 'E:/projects/OESD/A/data/out/';
    DataFileDir           = 'E:/projects/OESD/A/data/in1/';
    XFocusScopeRange      = 500;
    NoiseList             = ['  0'; '  1'; '  2'; '  4'; '  8'; ' 16'; ' 32'; ' 64'; '128'; '256';];
    
    %--- frameRx parameters
    VideoSizeX   = 800;
    VideoSizeY   = 600;
    ShiftFactor  = 2;
    
    %--- pipes parameters
    VideoPipeTransferTimeout = 200;
    
    %---
    global PrgData;
    PrgData = struct( ...
                        'VideoSizeX', VideoSizeX, ...
                        'VideoSizeY', VideoSizeY, ...
                        'AlgList', AlgList, ...
                        'CmdPipeGblEna', CmdPipeGblEna, ...
                        'LensSetupTime', LensSetupTime, ...
                        'FuncFocusGraphHold', FuncFocusGraphHold,...
                        'PlotProfileAsStem',PlotProfileAsStem, ...
                        'MaxFocusPassNum', MaxFocusPassNum, ...
                        'ResultFileDir',ResultFileDir, ...
                        'MaxFuncFocus',MaxFuncFocus, ...
                        'MinFuncFocus',MinFuncFocus, ...
                        'ROI',[ROI ROI(3)], ...
                        'XFocusMinValue', XFocusMinValue, ...        
                        'XFocusMaxValue', XFocusMaxValue, ...
                        'XFocusInitValue', XFocusInitValue, ...
                        'XFocusScopeRange',XFocusScopeRange, ...
                        'FindMaxFocusIdxOffset',FindMaxFocusIdxOffset, ...
                        'ColorArray',[], ...
                        'NoiseList', NoiseList, ...
                        'ScopeColorArray',[], ...
                        'isFinished',0, ...
                        'currAlg',[], ...
                        'fileNum',1, ...
                        'dxROI', 0, ...,
                        'focusFuncDataValid',0, ...
                        'cmdJobRequestor',2, ...
                        'cmdValue',int32(0),...
                        'xFocusIdx',1, ...
                        'focusPassNum',1, ...
                        'xFocusVec',[], ...
                        'focusFuncBuf',[], ...
                        'cancelFocusFuncJob',0, ...
                        'xFocusScopeVec',[],...
                        'focusScopeVec',[],...
                        'xScopeIdx',1,...
                        'vecScopeIdx',1,...
                        'colorIdx',0, ...
                        'currNoise',0, ...,
                        'idxSelectSizeROI',1, ...
                        'frameSaveRequest', 0 ...
                     );
        
    videoImgBuf   = genBuf(VideoSizeY,VideoSizeX,'uint8');
    videoMathBuf  = genBuf(VideoSizeY,VideoSizeX,'single');
    subFrameQueue = zeros([ROI(3) ROI(3) AvgFrameNum],'single');
    avgSubFrame   = zeros([ROI(3) ROI(3)],'single');
    
    PrgData.xFocusVec = XFocusStartScanValue:XFocusStep:XFocusStopScanValue;
    %PrgData.xFocusVec = [0 300 100 200 270 240 220 250 160]';
    
    PrgData.focusFuncBuf = zeros(PrgData.MaxFocusPassNum,numel(PrgData.xFocusVec))+NaN; 
    
    %--- ui init
    PrgData.hs = createUi(videoImgBuf);
    
    [res, videoPipe, videoBuf, cmdPipe, ackPipe] = initIpPipes(VideoPipeEna,CmdPipeGblEna);
    if(res == 0)
            closeFigures;
            clear ipPipeCmd;
            return;
    end    

    %---
    VideoMode    = 3;
    
    ScannerReq   = 1;
    SliderReq    = 2;
    SingleReq    = 3;

    %---
    nVideoBuf     = 0;
    scannerRdy    = 0;
    lensSetupTime = -1;
    lensStable    = 1;
    avgIdx        = 1;
    
    dataFileNum   = 1;
    oldCmdValue = PrgData.cmdValue;
    
    %---
    while(~PrgData.isFinished)
        if(VideoPipeEna)
            i = 0;
            while((ipPipeCmd('isBufEmpty',videoPipe) == 0) || (i == 0))
                [status,videoWordsRvd] = ipPipeCmd('transferBuf',videoPipe,0,videoBuf,VideoPipeTransferTimeout);
                if(status ~= 0)
                    fprintf(1,'[rx] transferBuf status %d, bufSize: %d\n',status,videoWordsRvd);
                    break;
                end
                i = i + 1;
            end    
        else 
            pause(TestDelay);
        end
        
        jobTimeStart = tic;
        %--- video processing
        if(VideoPipeEna)
            [status, imgBufNum] = getRxFrame(VideoMode,videoBuf,videoWordsRvd,VideoSizeX,VideoSizeY,videoImgBuf,ShiftFactor,videoMathBuf);
            if(VideoMode == 3)
                sX = PrgData.ROI(1);
                sY = PrgData.ROI(2);
                eX = sX + PrgData.ROI(3)-1;
                eY = sY + PrgData.ROI(4)-1;
                subFrame = videoMathBuf(sY:eY,sX:eX);
                if(PrgData.currNoise ~= 0)
                    %subFrame = PrgData.currNoise*randn(size(subFrame)); % TEST (see at GLVA)
                    subFrame = subFrame + PrgData.currNoise*randn(size(subFrame));
                    videoImgBuf(sY:eY,sX:eX) = subFrame/(2^ShiftFactor);
                end    
                if(AvgFrameNum > 1)
                    if(PrgData.ROI(3) ~= size(avgSubFrame,1))
                        avgSubFrame = zeros([PrgData.ROI(3) PrgData.ROI(3)],'single');
                        subFrameQueue = zeros([PrgData.ROI(3) PrgData.ROI(3) AvgFrameNum],'single');
                        avgIdx = 1;
                    end    
                    subFrameQueue(:,:,avgIdx) = subFrame;
                    avgIdx = avgIdx + 1;
                    if(avgIdx > AvgFrameNum)
                        avgIdx = 1;
                    end
                    avgSubFrame = sum(subFrameQueue,3)/AvgFrameNum;
                end
                %figure(3);                  % check subframe extraction
                %imshow(subFrame,[0 1023]);  % check subframe extraction
            end    
            if(~PrgData.isFinished)
                set(PrgData.hs.hVideoImg,'CData',videoImgBuf);
            end    
        end
        
        %--- focus functional computing
        if(VideoPipeEna)
            if(AvgFrameNum > 1)
                focusFuncVal = fFocusFunc(nVideoBuf,avgSubFrame);
            else
                focusFuncVal = fFocusFunc(nVideoBuf,subFrame);
            end    
        else
            focusFuncVal = testFocusFunc(nVideoBuf);
        end    
        focusScope(focusFuncVal);
        
        %---
        if(lensSetupTime >= 0)
            lensSetupTime = lensSetupTime + 1;
            if(lensSetupTime >= PrgData.LensSetupTime)
                lensStable = 1;
                lensSetupTime = -1;
            end    
        end
        
        %--- cmd/ack processing
        cmdPipeStatus = -1;
        if(PrgData.cmdJobRequestor)
            [cmdPipeStatus,cmdSent] = sendCmd(PrgData.cmdValue,cmdPipe,ackPipe);
            if(cmdPipeStatus < 0)
                fprintf(1,'[ERROR] sendCmd status: %d\n',cmdPipeStatus);
                break;
            end
            if(cmdSent == 1)
                lensStable = 0;
                lensSetupTime = 0;
                %fprintf(1,'[INFO] cmd sent at buf=%5d\n',nVideoBuf);
            end
        end

        %---
        if(PrgData.frameSaveRequest && (cmdPipeStatus ~= 0))
            [dataFileNum] = saveDataFile(videoBuf,PrgData.cmdValue,dataFileNum,DataFileDir);
            PrgData.frameSaveRequest = 0;
        end    
        
        %---
        if(~PrgData.isFinished && PrgData.cmdJobRequestor && (cmdPipeStatus == 1))
             if(PrgData.cmdValue ~= oldCmdValue)
                 set(PrgData.hs.hFocusValue,'String',int2str(PrgData.cmdValue));
                 oldCmdValue = PrgData.cmdValue;
             end    
            %fprintf(1,'bufNum: %5d, cmdValue: %d, cmdPipeStatus: %d, requestor: %d\n',nVideoBuf,PrgData.cmdValue,cmdPipeStatus,PrgData.cmdJobRequestor);
            switch PrgData.cmdJobRequestor
                case ScannerReq
                    scannerRdy = 1;
                case SliderReq
                case SingleReq
                    set(PrgData.hs.hSlider,'Value',PrgData.cmdValue);
                otherwise
            end    
            PrgData.cmdJobRequestor = 0;
        end
        
        %---
        if(scannerRdy && lensStable)
            %fprintf(1,'[INFO] "dispFocusProfile" at buf=%5d\n',nVideoBuf);
            if(strcmp(PrgData.currAlg,'@LOG'))
                [dataFileNum] = saveDataFile(videoBuf,PrgData.cmdValue,dataFileNum,DataFileDir);
            end
            
            dispFocusProfile(focusFuncVal);
            scannerRdy = 0;
        end
        
        %---
        drawnow;
        jobTime = toc(jobTimeStart);
        %fprintf(1,'job time:     %10.0f ms\n',jobTime*1000);
        
        nVideoBuf = nVideoBuf + 1;
        if(rem(nVideoBuf,VideoPrintFactor) == 0)
            fprintf(1,'frameRxBuf received: %4d\n',nVideoBuf);
        end    
    end
    
    closeFigures;
    clear ipPipeCmd;
end

%--------------------------------------------------------------------------
function hs = createUi(imgBuf)
    import alg_utils.*;
    global PrgData;

    PrgData.ColorArray = [ ...
                           1.0 0.0 0.0;
                           0.0 0.0 1.0;
                           0.0 1.0 0.0;
                           0.0 1.0 1.0;
                           1.0 0.0 1.0;
                           1.0 1.0 0.0;
                           1.0 0.5 0.0;
                           1.0 0.0 0.5;
                           0.0 1.0 0.5;
                           0.5 1.0 0.0;
                           0.5 0.0 1.0;
                           0.0 0.5 1.0;
                         ];
    PrgData.colorIdx = 0;
    
    
    %---
    hs.hVideoFig = figure( ...
                   'Visible','off', ...
                   ...%'Name','Camera View', ...
                   'NumberTitle','off', ...
                   'Toolbar','none', ...
                   'Menubar','none', ...
                   'Color',[0.5 0.5 0.5], ...
                   'Colormap',gray(256), ...
                   'WindowButtonUpFcn', @fStopDragROI ...
                 );
    [hs.hVideoImg, hs.hVideoAxes] = initImg(imgBuf, hs.hVideoFig, [0.0 0.0 1 1], [0 255]);
    ROI = PrgData.ROI;
    hs.hLines = plotBorder(hs.hVideoAxes,PrgData.ROI(1),ROI(2),ROI(3),ROI(4),'r',[]);
    %set(hs.hVideoImg,'EraseMode','normal');
    set(hs.hLines(4),'ButtonDownFcn',{@fStartDragROI})
  
    %---
    hs.hUiFig = figure('Name','Liquid Lens Probe','NumberTitle','off','Visible','off','DeleteFcn',{@fFigDelete});
    
    %---
    hs.hProfileAxes = axes('Parent',hs.hUiFig,'OuterPosition',[0 0.55 1 0.45 ]);
    hold(hs.hProfileAxes,'on');
%     for n = 1:PrgData.MaxFocusPassNum
%         hs.hProfile(n) = plot(hs.hProfileAxes,PrgData.xFocusVec,PrgData.xFocusVec*NaN);
%         set(hs.hProfile(n),'Color',PrgData.ColorArray(1,:));
%     end    
    if(PrgData.MaxFuncFocus)
        set(hs.hProfileAxes, 'Color',[0.6 0.6 0.6],'XLim',[min(PrgData.xFocusVec) max(PrgData.xFocusVec)],'YLim',[PrgData.MinFuncFocus PrgData.MaxFuncFocus]);
    else
        set(hs.hProfileAxes, 'Color',[0.6 0.6 0.6],'XLim',[min(PrgData.xFocusVec) max(PrgData.xFocusVec)]);
    end    
    grid(hs.hProfileAxes);

    %---
    PrgData.xFocusScopeVec = 1:PrgData.XFocusScopeRange;
    PrgData.focusScopeVec = ones(size(PrgData.xFocusScopeVec))*NaN;
    PrgData.ScopeColorArray = [ 0.0 1.0 0.0; 0.0 0.5 0.0 ];
    hs.hTimeScopeAxes = axes('Parent',hs.hUiFig,'OuterPosition',[0 0.1 1 0.45 ]);
    hold(hs.hTimeScopeAxes,'on');
    for n =1:2
        hs.hScope(n) = plot(hs.hTimeScopeAxes,PrgData.xFocusScopeVec,PrgData.focusScopeVec);
        set(hs.hScope(n),'Color',PrgData.ScopeColorArray(n,:));
    end
    if(PrgData.MaxFuncFocus)
        set(hs.hTimeScopeAxes, 'Color',[0.1 0.4 0.2],'XLim',[PrgData.xFocusScopeVec(1) PrgData.xFocusScopeVec(end)],'YLim',[0 PrgData.MaxFuncFocus]);
    else
        set(hs.hTimeScopeAxes, 'Color',[0.1 0.4 0.2],'XLim',[PrgData.xFocusScopeVec(1) PrgData.xFocusScopeVec(end)]);
    end    
        
    grid(hs.hTimeScopeAxes);
    
    %---
    hs.hFocusFuncButton = uicontrol(hs.hUiFig, ...
                                   'Style','togglebutton', ...
                                   'String','<html><center>scan</center><center>start</center>', ...
                                   'BackgroundColor', [0.0 0.4 0.8], ...
                                   'FontSize',10, ...
                                   'Units','normalized', ...
                                   'Position',[0.0 0.0 0.1 0.1 ], ...
                                   'Callback', {@fFocusFuncButton } ...
                                   );
    %---
    hs.hProfileClearButton = uicontrol(hs.hUiFig, ...
                                   'Style','pushbutton', ...
                                   'Enable', 'on', ...
                                   'BackgroundColor', [0.8 0.8 0.0], ...
                                   'String','<html><center>clear</center><center>profile</center>', ...
                                   'FontSize',10, ...
                                   'Units','normalized', ...
                                   'Position',[0.1 0.0 0.1 0.1 ], ...
                                   'Callback', {@fProfileClearButton } ...
                                   );
    %---
    hs.hResultSaveButton = uicontrol(hs.hUiFig, ...
                                   'Style','pushbutton', ...
                                   'Enable', 'off', ...
                                   'String','<html><center>save</center><center>result</center>', ...
                                   'FontSize',10, ...
                                   'Units','normalized', ...
                                   'Position',[0.2 0.0 0.1 0.1 ], ...
                                   'Callback', {@fResultSaveButton } ...
                                   );
    %---
    hs.hFrameSaveButton = uicontrol(hs.hUiFig, ...
                                   'Style','pushbutton', ...
                                   'Enable', 'on', ...
                                   'String','<html><center>save</center><center>frame</center>', ...
                                   'FontSize',10, ...
                                   'Units','normalized', ...
                                   'Position',[0.3 0.0 0.1 0.1 ], ...
                                   'Callback', {@fFrameSaveButton } ...
                                   );
                               
    %---
    sliderRange = PrgData.XFocusMaxValue - PrgData.XFocusMinValue;
    hs.hSlider = uicontrol(hs.hUiFig, ...
                                   'Style','slider', ...
                                   'Max',PrgData.XFocusMaxValue, ...
                                   'Min',PrgData.XFocusMinValue, ...
                                   'SliderStep', [1/sliderRange 1/(0.02*sliderRange)], ...
                                   'Units','normalized', ...
                                   'Position',[0.4 0.0 0.6 0.05 ], ...
                                   'Callback', {@fSlider}, ...
                                   'Value', PrgData.XFocusInitValue ... 
                            );
                       
    hs.hFocusValue = uicontrol(hs.hUiFig, ...
                                   'Style','text', ...
                                   'Units','normalized', ...
                                   'Position',[0.00 0.85 0.07 0.045 ], ...
                                   'HorizontalAlignment','right', ...
                                   'FontSize', 20, ...
                                   'FontName', 'CourierNew', ...
                                   'BackGroundColor', [0 0 1], ... %get(hs.hUiFig,'Color'), ...
                                   'ForegroundColor', [0 1 1], ...
                                   'String', int2str(PrgData.XFocusInitValue) ... 
                              );

    hs.hCV = uicontrol(hs.hUiFig, ... % coefficient of variation
                                   'Style','text', ...
                                   'Units','normalized', ...
                                   'Position',[0.00 0.75 0.07 0.045 ], ...
                                   'HorizontalAlignment','right', ...
                                   'FontSize', 20, ...
                                   'FontName', 'CourierNew', ...
                                   'BackGroundColor', [0.3 0.3 0.7], ... 
                                   'ForegroundColor', [0 1 1], ...
                                   'String', [] ... 
                              );
                          
    %---                        
    hs.hAlgSelect = uicontrol(hs.hUiFig, ...
                                       'Style', 'popup',...
                                       'String', PrgData.AlgList, ...
                                       'FontSize',10, ...
                                       'Units','normalized', ...
                                       'BackgroundColor', [0.0 0.0 0.2], ...
                                       'ForegroundColor', [1.0 1.0 0.0], ...
                                       'Position', [0.0 0.9 0.1 0.1],...
                                       'Callback', {@fAlgSelect} ...
                             );                       
                         
    currAlgIdx = get(hs.hAlgSelect,'Value');
    PrgData.currAlg = PrgData.AlgList(currAlgIdx,:);

    %---                        
    hs.hROISizeSelect = uicontrol(hs.hUiFig, ...
                                       'Style', 'popup',...
                                       'String', [ '256'; '128'; ' 64'; ' 32'; ], ... 
                                       'FontSize',10, ...
                                       'Units','normalized', ...
                                       'BackgroundColor', [0.0 0.0 0.4], ...
                                       'ForegroundColor', [1.0 1.0 0.0], ...
                                       'Position', [0.0 0.15 0.06 0.1],...
                                       'Callback', {@fROISizeSelect} ...
                             );
                         
    %---                        
    hs.hNoiseSelect = uicontrol(hs.hUiFig, ...
                                       'Style', 'popup',...
                                       'String', PrgData.NoiseList, ... 
                                       'FontSize',10, ...
                                       'Units','normalized', ...
                                       'BackgroundColor', [0.0 0.0 0.4], ...
                                       'ForegroundColor', [1.0 1.0 0.0], ...
                                       'Position', [0.0 0.3 0.06 0.1],...
                                       'Callback', {@fNoiseSelect} ...
                             );
    currNoiseIdx = get(hs.hNoiseSelect,'Value');
    PrgData.currNoise = str2double(PrgData.NoiseList(currNoiseIdx,:));                        

    %---
    captureBG = get(hs.hUiFig,'Color');
    captureFontSize = 10;
    uicontrol(hs.hUiFig,'Style','text','Units','normalized','Position',[0.0 0.90 0.07 0.03 ],'String','Focus Value','BackgroundColor',captureBG,'FontSize',captureFontSize);
    uicontrol(hs.hUiFig,'Style','text','Units','normalized','Position',[0.0 0.80 0.07 0.03 ],'String','CV','BackgroundColor',captureBG,'FontSize',captureFontSize);
    uicontrol(hs.hUiFig,'Style','text','Units','normalized','Position',[0.0 0.40 0.07 0.03 ],'String','Noise','BackgroundColor',captureBG,'FontSize',captureFontSize);
    uicontrol(hs.hUiFig,'Style','text','Units','normalized','Position',[0.0 0.25 0.07 0.03 ],'String','ROI size','BackgroundColor',captureBG,'FontSize',captureFontSize);
    
    %---
    align([hs.hFocusFuncButton hs.hSlider],'VerticalAlignment','Bottom');
    set(hs.hUiFig,'units','normalized','outerposition', [-0.68 0.0 0.67 0.67]);
    set(hs.hVideoFig,'units','normalized','outerposition',[-0.34  0.67 0.3 0.32]);
    %set(hs.hUiFig,'units','normalized','outerposition', [0.02 0.1 0.67 0.67]);
    %set(hs.hVideoFig,'units','normalized','outerposition',[0.7  0.67 0.3 0.32]);
    
    %---
    guidata(hs.hUiFig,struct('hs',hs));
    set(hs.hUiFig,'Visible','on');
    set(hs.hVideoFig,'Visible','on');
    drawnow;
end

%--------------------------------------------------------------------------
function fFigDelete(~,~)
    global PrgData;
    PrgData.isFinished = 1;
    closeFigures;
end

%--------------------------------------------------------------------------
function fFocusFuncButton(~,~)
    global PrgData;
    
    if(PrgData.cmdJobRequestor == 0)
        PrgData.cmdJobRequestor = 1;
        PrgData.cancelFocusFuncJob = 0;
        PrgData.focusFuncDataValid = 0;
        PrgData.focusFuncBuf = PrgData.focusFuncBuf + NaN;
        PrgData.xFocusIdx = 1;
        PrgData.cmdValue = cast(PrgData.xFocusVec(PrgData.xFocusIdx),'int32');
        PrgData.focusPassNum = 1;
        PrgData.colorIdx = PrgData.colorIdx + 1;
        if(PrgData.colorIdx > size(PrgData.ColorArray,1))
            PrgData.colorIdx = 1;
        end    
        for n = 1:PrgData.MaxFocusPassNum
            isEmptyAxis = isempty(get(PrgData.hs.hProfileAxes,'Children'));
            if(PrgData.FuncFocusGraphHold || isEmptyAxis)
                PrgData.hs.hProfile(n) = plot(PrgData.hs.hProfileAxes,PrgData.xFocusVec,PrgData.xFocusVec*NaN);
                if(PrgData.PlotProfileAsStem)
                    set(PrgData.hs.hProfile(n),'Color',PrgData.ColorArray(PrgData.colorIdx,:),'LineStyle','none','Marker','s','MarkerSize',5);
                else    
                    set(PrgData.hs.hProfile(n),'Color',PrgData.ColorArray(PrgData.colorIdx,:));
                end    
            else
                set(PrgData.hs.hProfile(n),'YData',PrgData.xFocusVec*NaN,'Color',PrgData.ColorArray(PrgData.colorIdx,:));
            end
        end
        set(PrgData.hs.hSlider,'Enable','off'); 
        set(PrgData.hs.hResultSaveButton,'Enable','off');
        set(PrgData.hs.hFrameSaveButton,'Enable','off');
        set(PrgData.hs.hProfileClearButton,'Enable','off');
        set(PrgData.hs.hAlgSelect,'Enable','off');
        set(PrgData.hs.hFocusFuncButton,'String','<html><center>scan</center><center>cancel</center>');
        return;
    end
    if(PrgData.cmdJobRequestor == 1)
        PrgData.cancelFocusFuncJob = 1;
        return;
    end    
end

%--------------------------------------------------------------------------
function fResultSaveButton(~,~)
    global PrgData;
    
    set(PrgData.hs.hResultSaveButton,'Enable','off');
    fileName = sprintf('%s/afData[%02d]',PrgData.ResultFileDir,PrgData.fileNum);
    fileNum = PrgData.fileNum;
    xFocusVec = PrgData.xFocusVec;
    focusFuncBuf = PrgData.focusFuncBuf;
    save(fileName,'fileNum','xFocusVec','focusFuncBuf');
    PrgData.fileNum = PrgData.fileNum + 1;
end

%--------------------------------------------------------------------------
function fFrameSaveButton(~,~)
    global PrgData;
    PrgData.frameSaveRequest = 1;
end

%--------------------------------------------------------------------------
function fProfileClearButton(~,~)
    global PrgData;
    
    %---
    cla(PrgData.hs.hProfileAxes);
    PrgData.colorIdx = 0;
    
    %---
    PrgData.focusScopeVec = PrgData.focusScopeVec + NaN;
    PrgData.xScopeIdx = 1;
    for n = 1:2
        set(PrgData.hs.hScope(n),'YData',PrgData.focusScopeVec);
    end    
end

%--------------------------------------------------------------------------
function fSlider(hObject,~)
    global PrgData;
    if(PrgData.cmdJobRequestor == 0)
        PrgData.cmdValue = cast(round(get(hObject,'Value')),'int32');
        PrgData.cmdJobRequestor = 2;
        return;
    end    
end

%--------------------------------------------------------------------------
function fAlgSelect(hObject,~)
    global PrgData;
    currAlgIdx = get(hObject,'Value');
    PrgData.currAlg = PrgData.AlgList(currAlgIdx,:);
end

%--------------------------------------------------------------------------
function fNoiseSelect(hObject,~)
    global PrgData;
    currNoiseIdx = get(hObject,'Value');
    PrgData.currNoise = str2double(PrgData.NoiseList(currNoiseIdx,:));          
end

%--------------------------------------------------------------------------
function fROISizeSelect(hObject,~)
    global PrgData;
    import alg_utils.*
    
    currIdx = get(hObject,'Value');
    strROI = get(hObject,'String');
    sizeROI = str2double(strROI(currIdx,:));
    if((PrgData.ROI(1) + sizeROI > PrgData.VideoSizeX) || (PrgData.ROI(2) + sizeROI > PrgData.VideoSizeY))
        set(PrgData.hs.hROISizeSelect,'Value', PrgData.idxSelectSizeROI);
        return;
    end
    PrgData.idxSelectSizeROI = currIdx;
    PrgData.ROI(3) = sizeROI;
    PrgData.ROI(4) = sizeROI;
    PrgData.hs.hLines = plotBorder(PrgData.hs.hVideoAxes,PrgData.ROI(1),PrgData.ROI(2),PrgData.ROI(3),PrgData.ROI(4),'r',PrgData.hs.hLines);
end


%--------------------------------------------------------------------------
function closeFigures
    figHandles = findall(0,'Type','figure');
    delete(figHandles);
end

%--------------------------------------------------------------------------
function [res, videoPipe, videoBuf, cmdPipe, ackPipe] = initIpPipes(videoPipeEna, lensSteady)
    path(path,'..\sw64\ip_pipe\src\math\');
    import ip_pipe.*
   
    res = 1;
    videoPipe = [];
    cmdPipe   = [];
    ackPipe   = [];
    
    %--- frameRx pipe parameters
    VideoPipeInitTimeout     = 1000;
    VideoPipeChunkSize       = 1024*1024;
    VideoPipeChunkNum        = 256;
    VideoPipeName            = 'toMath';

    %--- controller cmd pipe parameters
    CmdPipeName            = 'ControllerCmdPipe';
    CmdPipeChunkSize       = 4;
    CmdPipeChunkNum        = 4;
    CmdPipeInitTimeout     = 200;

    %--- controller ack pipe parameters
    AckPipeName            = 'ControllerAckPipe';
    AckPipeChunkSize       = 4;
    AckPipeChunkNum        = 4;
    AckPipeInitTimeout     = 200;
    
    %---
    videoElemSize = sizeof('uint16');
    videoBuf     = genBuf(1,VideoPipeChunkSize/videoElemSize,'uint16');
 
    %---
    if(videoPipeEna)
        [status, videoPipe] = ipPipeStart(VideoPipeName,'rx',VideoPipeChunkSize,VideoPipeChunkNum,VideoPipeInitTimeout);
        if(status ~= 0)
            res = 0;
            return;
        end
    end
    
    %---
    if(lensSteady)
        [status, cmdPipe] = ipPipeStart(CmdPipeName,'tx',CmdPipeChunkSize,CmdPipeChunkNum,CmdPipeInitTimeout);
        if(status ~= 0)
            res = 0;
            return;
        end
    end
    
    %---
    if(lensSteady)
        [status, ackPipe] = ipPipeStart(AckPipeName,'rx',AckPipeChunkSize,AckPipeChunkNum,AckPipeInitTimeout);
        if(status ~= 0)
            res = 0;
            return;
        end
        ackValueBuf = zeros(1,AckPipeChunkNum,'int32');
        if(~ipPipeCmd('isBufEmpty',ackPipe))
            ipPipeCmd('transferBuf',ackPipe,0,ackValueBuf,0);
        end    
    end
end

%--------------------------------------------------------------------------
function [status, cmdSent] = sendCmd(cmdValue,cmdPipe,ackPipe)
    global PrgData;
    persistent cmdPipePhase;
    persistent ackWaitCounter;
    persistent ackValue;
    persistent cmdValueReg;
    
    if(isempty(cmdPipePhase))
        cmdPipePhase   = 0;
        ackWaitCounter = 0;
        ackValue    = zeros(1,1,'int32');
        cmdValueReg = zeros(1,1,'int32');
    end
    
    %---
    cmdSent = 0;
    CmdPipeTransferTimeout   = 200;
    AckPipeTransferTimeout   =  10;

    if(~PrgData.CmdPipeGblEna)
        if(cmdPipePhase == 0)
            cmdPipePhase = 1;
            status = 0;
        else
            cmdPipePhase = 0;
            status = 1;
        end
        return;
    end    
    
    %---
    if(cmdPipePhase == 0) %--- send command
        ackWaitCounter = 0;
        [status,cmdWordsTxd] = ipPipeCmd('transferBuf',cmdPipe,1,cmdValue,CmdPipeTransferTimeout);
        if(status ~= 0)
            fprintf(1,'[tx] transferBuf status %d, bufSize: %d\n',status,cmdWordsTxd);
            status = -1;
        else
            cmdValueReg  = cmdValue;
            cmdPipePhase = 1;
            status = 0;
            cmdSent = 1;
        end
    else %--- wait for ack
        if(~ipPipeCmd('isBufEmpty',ackPipe))
            [status, ackWordsRvd] = ipPipeCmd('transferBuf',ackPipe,0,ackValue,AckPipeTransferTimeout);
            if(status ~= 0)
                fprintf(1,'[rx] transferBuf status %d, bufSize: %d\n',status,ackWordsRvd);
                status = -2;
            else
                if(ackValue == cmdValueReg)
                    cmdPipePhase = 0;
                    status = 1;
                    %fprintf(1,'[INFO] ack recived. value: %d\n',ackValue);
                else
                    fprintf(1,'[ERROR] bad ack recived. ackValue: %d, cmdValue: %d\n',ackValue,cmdValueReg);
                    status = -3;
                end    
            end    
        else
            ackWaitCounter = ackWaitCounter + 1;
            if(ackWaitCounter >= 2)
                fprintf(1,'[ERROR] ackWaitCounter: %d\n',ackWaitCounter);
                status = -4;
            else
                status = 0;
            end    
        end    
    end 
end

%--------------------------------------------------------------------------
function dispFocusProfile(focusFuncVal)
    global PrgData;

    if(PrgData.cancelFocusFuncJob)
        endJob(0);
        return;
    end
   
    xFocusVecLen = numel(PrgData.xFocusVec);
    PrgData.focusFuncBuf(PrgData.focusPassNum,PrgData.xFocusIdx) = focusFuncVal;
    set(PrgData.hs.hProfile(PrgData.focusPassNum),'YData',PrgData.focusFuncBuf(PrgData.focusPassNum,:));
    PrgData.xFocusIdx = PrgData.xFocusIdx + 1;

    PrgData.cmdJobRequestor = 1;
    if(PrgData.xFocusIdx > xFocusVecLen)
        PrgData.xFocusIdx = 1;
        if(PrgData.focusPassNum == PrgData.MaxFocusPassNum)
            endJob(1);
            % PrgData.focusFuncBuf now is ready for logging
        else    
            currColor = get(PrgData.hs.hProfile(PrgData.focusPassNum),'Color');
            set(PrgData.hs.hProfile(PrgData.focusPassNum),'Color',currColor*0.5);
            PrgData.focusPassNum = PrgData.focusPassNum + 1;
        end    
    end
    if(PrgData.cmdJobRequestor == 1)
        PrgData.cmdValue = cast(PrgData.xFocusVec(PrgData.xFocusIdx),'int32');
    end    
    
    %---
    function endJob(dataValid)
        PrgData.cmdJobRequestor = 0;
        set(PrgData.hs.hSlider,'Enable','on');
        set(PrgData.hs.hAlgSelect,'Enable','on');
        set(PrgData.hs.hSlider,'Value',PrgData.xFocusVec(end));
        set(PrgData.hs.hFocusFuncButton,'Value',0,'String','<html><center>scan</center><center>start</center>');
        PrgData.focusFuncDataValid = dataValid;
        %PrgData.LensSetupTime = PrgData.LensSetupTime + 1;
        %PrgData.LensSetupTime
        set(PrgData.hs.hProfileClearButton,'Enable','on');
        set(PrgData.hs.hFrameSaveButton,'Enable','on');
        if(dataValid)
            fprintf(1,'-------\n');
            for k = 1:PrgData.MaxFocusPassNum
                maxFocusFunc = max(PrgData.focusFuncBuf(k,(1+PrgData.FindMaxFocusIdxOffset):end));
                idxMax = find(PrgData.focusFuncBuf(k,:) == maxFocusFunc,1);
                algIdx = get(PrgData.hs.hAlgSelect,'Value');
                fprintf(1,'Alg: %4s, pass: %2d, offset: %1d, best focus at: %4d\n',PrgData.AlgList(algIdx,:),k,PrgData.FindMaxFocusIdxOffset,PrgData.xFocusVec(idxMax));
                if(k == PrgData.MaxFocusPassNum)
                    PrgData.cmdValue = cast(PrgData.xFocusVec(idxMax),'int32');
                    PrgData.cmdJobRequestor = 3;
                end    
            end
            set(PrgData.hs.hResultSaveButton,'Enable','on');
        end
    end    
end

%--------------------------------------------------------------------------
function focusScope(focusFuncVal)
    global PrgData;
    
    if(PrgData.isFinished)
        return;
    end    
    
    PrgData.focusScopeVec(PrgData.xScopeIdx) = focusFuncVal;
    RangeSize = 50;
    if(rem(PrgData.xScopeIdx,RangeSize) == 0)
        range = (PrgData.xScopeIdx-RangeSize+1):PrgData.xScopeIdx;
        CV = std(PrgData.focusScopeVec(range))/mean(PrgData.focusScopeVec(range));
        strCV = sprintf('%4.1f',CV*100);
        set(PrgData.hs.hCV,'String',strCV);
    end    
    PrgData.xScopeIdx = PrgData.xScopeIdx + 1;
    if(PrgData.xScopeIdx > PrgData.XFocusScopeRange)
        PrgData.xScopeIdx = 1;
        set(PrgData.hs.hScope(PrgData.vecScopeIdx),'Color',PrgData.ScopeColorArray(2,:),'YData',PrgData.focusScopeVec);
        if(PrgData.vecScopeIdx == 1)
            PrgData.vecScopeIdx = 2;
        else
            PrgData.vecScopeIdx = 1;
        end
        PrgData.focusScopeVec = PrgData.focusScopeVec + NaN;
        set(PrgData.hs.hScope(PrgData.vecScopeIdx),'YData',PrgData.focusScopeVec,'Color',PrgData.ScopeColorArray(1,:));
    else    
        set(PrgData.hs.hScope(PrgData.vecScopeIdx),'YData',PrgData.focusScopeVec);
    end    
end

%--------------------------------------------------------------------------
function [focusFunc] = testFocusFunc(nVideoBuf,~)
    global PrgData;
    
    switch PrgData.currAlg
        case 'TENG'
            noise = randi(30);
        case 'GLVA'
            noise = 0;
        otherwise
            noise = 10;
    end    
    
    focusFunc = rem(nVideoBuf + noise,100);
end

%--------------------------------------------------------------------------
function [focusFunc] = fFocusFunc(~,sFrame)
    global PrgData;
    import alg_utils.*;
    
    if(strcmp(PrgData.currAlg,'@LOG'))
        focusFunc = 1;
    else
        focusFunc = fmeasure(sFrame,PrgData.currAlg,[]);
    end    
end

%--------------------------------------------------------------------------
function fStartDragROI(~,~)
    global PrgData;
    
    set(PrgData.hs.hVideoFig,'WindowButtonMotionFcn',{@fDraggingROI});
    crd = get(PrgData.hs.hVideoAxes,'CurrentPoint');
    PrgData.dxROI = ceil(crd(1)) - PrgData.ROI(1);
end

%--------------------------------------------------------------------------
function fDraggingROI(~,~)
    global PrgData;
    import alg_utils.*
    
    crd = get(PrgData.hs.hVideoAxes,'CurrentPoint');
    x0 = ceil(crd(1,1));
    y0 = ceil(crd(1,2));
    x0 = x0 - PrgData.dxROI;

    if((x0 < 1) || ((x0 + PrgData.ROI(3)) > PrgData.VideoSizeX) || (y0 < 1) || ((y0 + PrgData.ROI(4)) > PrgData.VideoSizeY))
        return;
    end    
    PrgData.ROI(1) = x0;
    PrgData.ROI(2) = y0;
    PrgData.hs.hLines = plotBorder(PrgData.hs.hVideoAxes,PrgData.ROI(1),PrgData.ROI(2),PrgData.ROI(3),PrgData.ROI(4),'r',PrgData.hs.hLines);
end

%--------------------------------------------------------------------------
function fStopDragROI(~,~)
    global PrgData;
    
    set(PrgData.hs.hVideoFig,'WindowButtonMotionFcn','');
end
