%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
classdef TVideoGenConst < TVideoGen
    %-----------------------------
    properties(GetAccess = 'protected', SetAccess = 'protected')
        PixelValue_m;
    end

    %-----------------------------
    methods
        function Obj = TVideoGenConst(DEV_Addr_,FrameSize_,  LineSize_, PixBitsWidth_, PixelValue_)
            Obj = Obj@TVideoGen(DEV_Addr_,FrameSize_,  LineSize_, PixBitsWidth_);
            Obj.PixelValue_m = PixelValue_;
        end
        
        function [Obj, Pixel] = GetPixel(Obj)
            Pixel = Obj.PixelValue_m;
        end    
    end    
end    