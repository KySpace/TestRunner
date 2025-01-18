% Video writer
function regvw(entry_vw, io, q)
arguments
    entry_vw        cell
    io              IOManager
    q               QueueManager
end
    for i_v = 1 : numel(entry_vw)
    op = @(name, dflt) lensgetop(name, dflt, entry_vw{i_v});
    need = @(name) lensget(name, [], entry_vw{i_v});
    val_is_enabled = op("Enabled", true);
    if val_is_enabled
        val_tit = need("Title");
        val_args = op("ArgsOpts", {});
        val_src = need("UpdateSource");
        val_addto = need("AddTo");
        [setter, destructor] = videowritersetter(val_tit, val_args, io.devices.savepath, val_src, val_addto);
        q.register("prep", "→", setter, "set up video writer: " + val_tit);
        q.register("post", "→", destructor, "close video writer: " + val_tit);
        q.register("panic", "→", destructor, "close video writer: " + val_tit);
    end
    end
end

function [setter, destructor] = videowritersetter(tit, opts, dir, src, val_addto)
    arguments
        tit         string
        opts        cell
        dir
        src         string
        val_addto   string
    end        
    name_vw = @(idx) "vw_" + tit + "_" + num2str(idx);
    path_vw = @(idx) dir + "/" + name_vw(idx);
    function set(io, idx, ~)
        if exist(path_vw(idx), "file"); delete(path_vw(idx)); end
        vw = VideoWriter(path_vw(idx), opts{:});
        io.visuals.(name_vw(idx)) = vw;
        open(vw);
        function grabframe(varargin)
            fig = io.visuals.(src);
            writeVideo(vw, getframe(fig));
        end
        addto = evalinio(io, val_addto);
        addto.reg("→", @grabframe, "capture frame: " + tit)
    end
    function destruct(io, idx, ~)
        if isfield(io.visuals, name_vw(idx))
            vw = io.visuals.(name_vw(idx));
            close(vw);
            delete(vw);
            io.visuals = rmfieldifexists({name_vw(idx)}, io.visuals);
        end
    end    
    warning('off', 'MATLAB:audiovideo:VideoWriter:mp4FramePadded');
    setter = @set;
    destructor = @destruct;
end

