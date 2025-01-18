function regvis(entry_vis, ~, q)
arguments
    entry_vis       cell
    ~            
    q               QueueManager
end
    for i_v = 1 : numel(entry_vis)
    op = @(name, dflt) lensgetop(name, dflt, entry_vis{i_v});
    need = @(name) lensget(name, [], entry_vis{i_v});
    val_is_enabled = op("Enabled", true);
    val_ty = need("Type");
    if val_is_enabled
        switch val_ty
            case "Figure"
                val_figname = need("FieldName");
                val_setter = need("Setter");
                val_setat = findsetatauto(entry_vis{i_v}, key_setat="SetAt");
                val_tolabel = op("Label", true);
                [setfig, labelfig, indicator] = figsetter(val_setter, val_figname);
                q.register(val_setat, "→", setfig, "Set figure (" + val_figname + "): " + val_figname);
                if val_tolabel
                    q.register("prep", "→", labelfig, "Label the pertest index and varying dictionary");
                end
                framesz = op("FrameSize", []);
                if ~isempty(framesz)
                    q.register("prep", "→", frameszsetter(val_figname, framesz), "set the frame size to: " + num2str(framesz));
                end
                val_usrc = need("UpdateSource");
                val_addto = need("AddTo");
                
                updaters = need("Updaters");
                for i_u = 1 : numel(updaters)
                    u = updaters{i_u};
                    u.Name = val_figname + "_" + u.Name;
                    q.register(val_setat, "→", updatersetter(u, val_usrc, val_addto, q), "add updater: " + u.Name);
                end
                q.register(val_setat, "→", indicator, "indicate the updates completed: " + "figname");
        end
    end
    end
end

function setsz = frameszsetter(figname, sz)
    function set(io, idx, ~)
        fig = io.visuals.(figname);
        topleft = tern(idx==1, [0 0], fig.Position(1:2)); 
        fig.Position = [topleft sz];
    end
    setsz = @set;
end

function [setfig, labelit, indicate] = figsetter(val_setter, figname)
arguments
    val_setter      string
    figname         string
end
    name_ann_iter = figname + "_pertest_ann";
    function set(io, ~, ~)
        [fig, updaters, gobj] = evalinio(io, val_setter);
        io.visuals.(figname) = fig;
        io.updaters = extractfieldsall(updaters, io.updaters, @(s) figname + "_" + s);
        io.visuals  = extractfieldsall(gobj    , io.visuals , @(s) figname + "_" + s);
    end
    % prep stage
    function labeler(io, idx, dict)        
        if ~isfield(io.visuals, name_ann_iter) || ~isvalid(io.visuals.(name_ann_iter))
            io.visuals.(name_ann_iter) = annotation(io.visuals.(figname), ...
                "textbox", [0 0.94 1 0.06], ...
                LineStyle="none", String="time:", ...
                Interpreter="none");            
        end
        ann = io.visuals.(name_ann_iter);        
        ann.String = runbrief(io.schemeinfo.fn_vary, dict, idx, io.multidicts.maxrun);
        ann.Color = [0.4 0.4 0.4];
        ann.FontName = "Consolas";
    end
    % Need improvement
    function labelindicator(io, ~, ~)
        ann = io.visuals.(name_ann_iter);
        ann.Color = [37 186 117]/256;
    end
    setfig = @set;
    labelit = @labeler;
    indicate = @labelindicator;
end

