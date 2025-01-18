classdef (Abstract) Iterator < DataContainer
    properties (Abstract)
        iter_max        (1,1)
        iter_now        (1,1)
        ioupdater       QueueUnit
        toproceed       
    end
    methods (Abstract)
        ready(~)
        reset(~)
        iter(~)
        wrapup(~)
    end
    methods
        function run(o)
            while o.iter_now <= o.iter_max && o.toproceed()
                o.iter();
                o.ioupdater.invoke(o.iter_now);
                o.iter_now = o.iter_now + 1;
            end
            o.ioupdater.clear;
            o.wrapup();
        end
    end
end