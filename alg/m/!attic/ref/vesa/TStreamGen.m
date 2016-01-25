%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
classdef TStreamGen
    %-----------------------------
    properties(Constant = true)
        DFM = hex2dec('800');
    end

    %-----------------------------
    properties(GetAccess = 'protected', SetAccess = 'protected')
        DEV_Addr_m;
    end

    %-----------------------------
    methods
        function Obj = TStreamGen(DEV_Addr_)
            Obj.DEV_Addr_m = DEV_Addr_;
        end    
        function DevAddr = GetDevAddr(Obj)
            DevAddr = Obj.DFM +  Obj.DEV_Addr_m;
        end    
    end

    %-----------------------------
    methods (Abstract)
        GetNextData(Obj);
    end    
end    