classdef (Abstract) DataObserver < DataContainer
    properties
        savepath
    end
    methods (Abstract)
        % initialize values
        init
        % ready should be called after loading the parameter, to fullfill the settings
        ready
        % clear resets statistic data
        clear
        % update should be tied to a recurring event
        update
        %
        final
    end
end