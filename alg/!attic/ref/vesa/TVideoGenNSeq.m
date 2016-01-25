%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
classdef TVideoGenNSeq < TVideoGen
    %-----------------------------
    properties(GetAccess = 'protected', SetAccess = 'protected')
        PixelValue_m;
    end
    %-----------------------------
    methods
        function Obj = TVideoGenNSeq(DEV_Addr_,FrameSize_,  LineSize_, PixBitsWidth_)
            Obj = Obj@TVideoGen(DEV_Addr_,FrameSize_,  LineSize_, PixBitsWidth_);
            Obj.PixelValue_m = 1;
        end
        
        function [Obj, Pixel] = GetPixel(Obj)
            if((Obj.LineCounter_m == 0) && (Obj.PixCounter_m == 0))
                Pixel = bitand(Obj.FrameCounter_m,Obj.MaxPixelValue_m);
            else    
                Pixel = Obj.PixelValue_m;
                Obj.PixelValue_m = Obj.PixelValue_m + 1;
                if(Obj.PixelValue_m > Obj.MaxPixelValue_m)
                    Obj.PixelValue_m = 0;
                end    
            end    
        end    
    end    
end    