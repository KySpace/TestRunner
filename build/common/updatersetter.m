function setupdate = updatersetter(u, s_src, s_addto, queue)
arguments
    u               struct      {mustHaveField(u, ["Name" "ArgsConv"])}
    s_src           string
    s_addto         string
    queue           QueueManager
end
    name = u.Name;
    conv = u.ArgsConv;
    function set(io, ~, ~)               
        function update(varargin)
            fun = io.updaters.(name); 
            src = evalinio(io, s_src);
            args = apply_c(conv, src);
            fun(args{:});
        end
        msg = "updater: " + name;
        if ismember(s_addto, queue.unitnames)
            queue.register(s_addto, "→", @update, msg)
        else
            addto = evalinio(io, s_addto);
            addto.reg("→", @update, msg);
        end
    end
    setupdate = @set;
end

