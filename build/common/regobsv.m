function regobsv(entry_obsv, ~, q)
arguments
    entry_obsv       cell
    ~      
    q       QueueManager
end
    for i_o = 1 : numel(entry_obsv)
    op = @(name, dflt) lensgetop(name, dflt, entry_obsv{i_o});
    need = @(name) lensget(name, [], entry_obsv{i_o});
    enabled = op("Enabled", true);
    if enabled
        val_constr = eval("@" + need("Constructor"));
        val_constrargs = op("ArgsConstr", {});
        name = need("FieldName"); 
        val_params = op("Parameters", struct());
        % setters
        [setter, loader, clearer, datataker, wrapperup] = obsvsetter(val_constr, val_constrargs, val_params, name);
        q.register("init", "→", setter, "Observer initialize: " + name);
        q.register("prep", "→", loader , "Observer load parameters: " + name);
        q.register("prep", "→", clearer, "Observer clear: " + name);
        q.register("post", "→", datataker, "take data to io from observer: " + name);
        q.register("final", "→", wrapperup, "wrap up from observer: " + name);
        % updaters
        val_usrc = need("UpdateSource");
        val_addto = need("AddTo");
        val_setat = findsetatauto(entry_obsv{i_o});
        val_updaters = need("Updaters");
        for i_u = 1 : numel(val_updaters)
            u = val_updaters{i_u};
            u.Name = name + "_" + u.Name;            
            q.register(val_setat, "→", updatersetter(u, val_usrc, val_addto, q), sprintf("REG@[%s]>> updater: %s", val_addto, u.Name));
        end
    end
    end
end

function [setter, loader, clearer, datataker, wrapperup] = obsvsetter(constr, constrargs, config, name)
    arguments
        constr          {mustBeFunctionHandle}
        constrargs      cell
        config          struct
        name            string
    end
    
    function set(io, ~, ~)
        constrargs_eval = map_c(@(s) tryevalinioifstring(s, io), constrargs);
        stat = constr(constrargs_eval{:});
        io.runner.(name) = stat;
        stat.loadconfig(config, io.multidicts);
        stat.init();
        io.updaters.(name + "_update") = @stat.update;
    end
    function loadparams(io, idx, dict)
        obs = io.runner.(name);
        if isfield(io.devices, "savepath")
            obs.savepath = sprintf("%s/%i", io.devices.savepath, idx);
        else
            obs.savepath = [];
        end
        obs.loadparams(dict);
        obs.ready(idx, dict);
    end
    function clearob(io, ~, ~)
        obs = io.runner.(name);
        obs.clear();
    end
    function takedata(io, ~, ~)
        obs = io.runner.(name);
        data_obsv = obs.exportdata(struct());
        io.data = extractfields(obs.datanames, data_obsv, io.data);
    end
    function wrapup(io, ~, ~)
        obs = io.runner.(name);
        obs.final();
    end
    setter = @set;
    loader = @loadparams;
    clearer = @clearob;
    datataker = @takedata;
    wrapperup = @wrapup;
end