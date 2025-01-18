function [io, queue] = buildmanagers(entry_config, filenames_reg)
arguments
    entry_config            struct
    filenames_reg           string
end
    % manages all class objects and resources.
    io = IOManager();
    % manages all task queues.
    % sometimes an instantiation would not clear the previous one, so it is
    % manually cleared.
    queue = QueueManager(); queue.clear();
    is_trial = entry_config.General.TrialRun;
    % All register functions need to accept arguments: (entry, io, queue)
    map_reg = mkregmap(filenames_reg, is_trial);
    function registerio(fn)
        if isKey(map_reg, fn)            
            fun = map_reg(fn);
            fun(entry_config.(fn), io, queue);
        end
    end
    fns = fieldnames(entry_config);
    for i_f = 1:numel(fns); registerio(fns{i_f}); end
end