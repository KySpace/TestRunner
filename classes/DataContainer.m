classdef (Abstract) DataContainer < handle
    properties (Constant, Abstract)
        confignames     string
        paramsnames     string
        datanames       string
    end
    properties
        idx_max
        ids_raw
    end
    methods
        function loadparams(o, params)
            for idx = 1 : length(o.paramsnames)
                fn = o.paramsnames(idx);
                o.(fn) = params.(fn);
            end
        end
        function loadconfig(o, config, multidicts)
            for idx = 1 : length(o.confignames)
                fn = o.confignames(idx);
                o.(fn) = config.(fn);
            end
            o.idx_max = multidicts.maxrun;
            o.ids_raw = multidicts.idxlist;
        end
        function data = exportdata(o, data)
            arguments
                o
                data = struct
            end
            for idx = 1 : length(o.datanames)
                fn = o.datanames(idx);
                data.(fn) = o.(fn);
            end
        end
    end
end