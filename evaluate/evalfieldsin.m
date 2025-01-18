function s = evalfieldsin(wksp, s_in)
arguments
    wksp            struct
    s_in            struct
end
    fn_in = fieldnames(s_in);
    for idx = 1 : length(fn_in) 
        fn = fn_in{idx};
        [wksp, val] = evalthis(wksp, fn, s_in.(fn));
        s.(fn) = val;
    end
end

function [wksp, val_o] = evalthis(wksp, name, val)
    assignwksp(wksp); 
    if isstring(val); val_o = tryeval(val); 
    elseif iscell(val)
        val_o = cell(size(val));
        for i_v = 1 : numel(val)
            v = val{i_v};
            [~, val_o{i_v}] = evalthis(wksp, [], v);
        end        
    elseif isstruct(val)
        fns = fieldnames(val);
        val_o = val;
        for i_f = 1 : numel(fns)
            fn = fns{i_f};
            [~, val_o.(fn)] = evalthis(wksp, [], val.(fn));
        end
    else 
        val_o = val;
    end
    if ~isempty(name); wksp.(name) = val_o; end
end

function val = tryeval(expr)
    try
        val = evalin("caller", expr);
    catch ME
        if isequal(ME.identifier, 'MATLAB:UndefinedFunction')
            val = expr; 
        else
            rethrow(ME);
        end
    end
end