function regiter(entry_iter, ~, q)
arguments
    entry_iter      struct
    ~      
    q               QueueManager
end
    op = @(name, dflt) lensgetop(name, dflt, entry_iter);
    need = @(name) lensget(name, [], entry_iter);    
    constr = eval("@" + need("Constructor"));
    val_constrargs = op("ArgsConstr", {});
    val_name = need("FieldName");        

    function set(io, ~, ~)
        iter = constr(val_constrargs{:});
        iter.ioupdater.clear();
        io.runner.(val_name) = iter;
    end
    function loadparams(io, ~, dict)
        iter = io.runner.(val_name);
        iter.loadparams(dict);
        iter.ready;
    end
    function run(io, ~, ~)
        iter = io.runner.(val_name);
        iter.run;
    end
    function takedata(io, ~, ~)
        io.data = io.runner.(val_name).exportdata(struct());
    end

    q.register("init", "→", @set        , "iterator initialize: " + val_name);
    q.register("prep", "→", @loadparams , "iterator ready: " + val_name);
    q.register("main", "→", @run        , "run the iterator: " + val_name);
    q.register("post", "→", @takedata   , "take data to io from iterator: " + val_name);

    entry_pause = op("Pause", []);
    if ~isempty(entry_pause)
        val_pause_time = entry_pause.Time;
        val_setat = findsetatauto(entry_pause);
        q.register(val_setat, "→", pausesetter(val_pause_time, entry_pause.AddTo), "register: add intentional pause / drawnow.");
    end
end