function varargout = evalinio(io, s)
arguments
    io      IOManager
    s       string
end
    if isprop(io, s); varargout = {io.(s)}; return; end
    expose(io.allstructs);
    [varargout{1:nargout}] = eval(s);
end

function expose(ss)
arguments
    ss       cell
end
    for i_s = 1 : numel(ss)
        s = ss{i_s};
        if ~isstruct(s); continue; end
        fns = fieldnames(s);
        for i_f = 1 : numel(fns)
            fn = fns{i_f};
            assignin("caller", fn, s.(fn));
        end
    end
end