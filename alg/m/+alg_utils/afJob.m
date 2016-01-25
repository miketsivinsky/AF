function [res] = afJob(jobList,jobIdxSet,justImgGen)
    import alg_utils.*;
    
    clc;
    res = 0;
    
    tStart = tic;
    for j=jobIdxSet
        tJobStart = tic;
        fprintf(1,'***************************************\n');
        fprintf(1,'[INFO] job %3d start\n',j);
        fprintf(1,'---------------------------------------\n');
        
        %---
        job = jobList(j);
        inDir = job.InDir;
        inFileList = dir(inDir);
        inFileList = inFileList([inFileList.isdir] == 0);
        inFileNum = numel(inFileList);
        algNum = numel(job.AlgNames);
        if(isempty(dir(job.OutDir)))
            mkdir(job.OutDir);
        end    

        %---
        
        outData(1:algNum) = struct( ...
                                'algName',               [], ...
                                'ROI',                   job.ROI, ...
                                'compTime',              0, ...
                                'focusArray',            zeros(1,inFileNum), ...
                                'fileNameArray',         char({inFileList.name}), ...
                                'focusMeasureArray',     zeros(1,inFileNum), ...
                                'normFocusMeasureArray', zeros(1,inFileNum) ...
                           );
        %---
        for n = 1:algNum
            outData(n).algName = char(job.AlgNames(n));
        end              
                  
        fprintf(1,'[INFO] inFileNum: %4d\n',inFileNum);
        fprintf(1,'[INFO] algNum:    %4d\n',algNum);
        
        %---
        for k = 1:inFileNum
            fileName = [inDir inFileList(k).name];
            [status, frame, lensControl] = readDataFile(fileName,job.FrameSize(1),job.FrameSize(2));
            if(status ~= 1)
                fprintf(1,'[ERROR] job %03d, file %20s read\n',j,inFileList(k).name);
                return;
            end
            
            %---
            sX = job.ROI(1);
            sY = job.ROI(2);
            eX = sX + job.ROI(3)-1;
            eY = sY + job.ROI(4)-1;
            sFrame = frame(sY:eY,sX:eX);
            
            %---
            if(justImgGen)
                if(bitand(justImgGen,1))
                    imgFileName = sprintf('%s%s.png',job.OutDir,inFileList(k).name(1:end-4));
                    imwrite(frame*64,imgFileName,'png');
                end
                if(bitand(justImgGen,2))
                    imgFileName = sprintf('%sr-%s[%3d %3d %3d %3d].png',job.OutDir,inFileList(k).name(1:end-4),job.ROI);
                    imwrite(sFrame*64,imgFileName,'png');
                end
                fprintf(1,'[INFO] job: %3d, file: %3d: %20s\n',j,k,inFileList(k).name);
                clear frame;
                clear sFrame;
                continue;
            end    
            
            clear frame;
    
            %---
            for n = 1:algNum
                fprintf(1,'[INFO] job: %3d, file: %3d, alg: %5s\n',j,k,outData(n).algName);
                outData(n).focusArray(k) = lensControl;
                tAlgStart = tic;
                %--- compute func focus
                fm = fmeasure(sFrame,outData(n).algName,[]);
                %---
                outData(n).compTime = outData(n).compTime + toc(tAlgStart);
                outData(n).focusMeasureArray(k) = fm;
            end
            clear sFrame;
        end
        
        %---
        if(justImgGen == 0)
            fprintf(1,'-----\n');
            for n = 1:algNum
                maxFuncFocus = max(outData(n).focusMeasureArray(:));
                outData(n).normFocusMeasureArray = outData(n).focusMeasureArray/maxFuncFocus;
                fprintf(1,'[INFO] job: %3d, alg: %5s, time: %10.2f s\n',j,outData(n).algName,outData(n).compTime);
            end
            fprintf(1,'-----\n');
            save([job.OutDir job.OutFile],'outData');
        else
            if(justImgGen == 1)
                res = 1;
                return;
            end    
        end
        clear outData;
        
        jobTime = toc(tJobStart);
        fprintf(1,'[INFO] job: %3d end, total time: %10.2f s\n\n',j,jobTime);
    end
    tStop = toc(tStart);
    fprintf(1,'[INFO] END, total time: %12.1f s\n\n',tStop);
    
    res = 1;
end