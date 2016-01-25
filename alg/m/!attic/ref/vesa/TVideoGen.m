%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
classdef TVideoGen < TStreamGen
    %-----------------------------
    properties(Constant = true)
        VFM = hex2dec('400');
        SOF = 1023;
        SOL = 1022;
        
        %--- enum State_t
        SOF1 = 1;
        SOF2 = 2;
        SOL1 = 3;
        SOL2 = 4;
        PIX  = 5;
    end
    
    %-----------------------------
    properties(GetAccess = 'protected', SetAccess = 'protected')
        LineSize_m;
        FrameSize_m;
        
        FrameCounter_m;
        LineCounter_m;
        PixCounter_m;
        State_m;
        MaxPixelValue_m;
    end
    
    %-----------------------------
    methods (Abstract)
        GetPixel(Obj);
    end    
   
    %-----------------------------
    methods
        function Obj = TVideoGen(DEV_Addr_,FrameSize_,  LineSize_, PixBitsWidth_)
            Obj = Obj@TStreamGen(DEV_Addr_);
            Obj.LineSize_m      = LineSize_;
            Obj.FrameSize_m     = FrameSize_;
            Obj.MaxPixelValue_m = 2^PixBitsWidth_ - 1;
            Obj = Obj.Reset;
        end
        
        function Obj = Reset(Obj)
            Obj.State_m = Obj.SOF1;
            Obj.FrameCounter_m = 0;
            Obj.LineCounter_m  = 0;
            Obj.PixCounter_m   = 0;
        end    
        
        function [Obj, Data] = GetNextData(Obj)
             switch (Obj.State_m)
                 case (Obj.SOF1)
                     Data = Obj.VFM + Obj.SOF;
                     Obj.State_m = Obj.SOF2;
                 case (Obj.SOF2)
                     Data = Obj.FrameCounter_m;
                     Obj.LineCounter_m = 0;         
                     Obj.State_m = Obj.SOL1;
                 case (Obj.SOL1)
                     Data = Obj.VFM + Obj.SOL;
                     Obj.State_m = Obj.SOL2;
                 case (Obj.SOL2)
                     Data = Obj.LineCounter_m;
                     Obj.PixCounter_m = 0;
                     Obj.State_m = Obj.PIX;
                 case (Obj.PIX)
                     [Obj, Data] = Obj.GetPixel;
                     Obj.PixCounter_m = Obj.PixCounter_m + 1;
                     if(Obj.PixCounter_m >= Obj.LineSize_m)
                        Obj.LineCounter_m = Obj.LineCounter_m + 1;
                        if(Obj.LineCounter_m >= Obj.FrameSize_m)
                            Obj.State_m = Obj.SOF1;
                            Obj.FrameCounter_m = Obj.FrameCounter_m + 1;
                            if(Obj.FrameCounter_m > Obj.SOF)
                                Obj.FrameCounter_m = 0;
                            end    
                        else
                            Obj.State_m = Obj.SOL1;
                        end
                     end    
                 otherwise
                     display('error in TVideoGen');
                     Data = hex2dec('FFF');
             end    
        end    
    end    
end    