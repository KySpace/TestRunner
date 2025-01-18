% evaluate the fields of the structure recursively with given dictionary/workspace
% the dictionary/workspace will grow by the preivously read fields.
% conversions are applied as well.
function s = evalconv(conv, l, wksp, s_in)
arguments
    conv                        % conversion rules
    l                           % extract level, level to extract from
    wksp            struct      % the already evaluated values
    s_in            
end
    p = "root";
    [~, s] = evalthis(conv, l, p, wksp, [], s_in);
end

% The recursive part
function [wksp, val_o] = evalthis(conv, l, p, wksp, name, val_in)
    arguments
        conv                    % conversion rules
        l     {mustBeInteger}   % extract level
        p       string          % current path
        wksp                    
        name
        val_in
    end
    assignwksp(wksp);
    c = matchpathpattern(conv, p);
    val = apply(pipe(c), val_in, wksp); 
    if iscell(val)
        val_o = cell(size(val));
        for i_v = 1 : numel(val)
            v = val{i_v};
            [wksp, val_o{i_v}] = evalthis(conv, l, p + "{}", wksp, [], v);
        end        
    elseif isstruct(val)
        fns = fieldnames(val);
        val_o = val;
        for i_f = 1 : numel(fns)
            fn = fns{i_f};
            % does not register to workspace if deeper than the extraction
            % level
            fnname = tern(l>=0, fn, []);
            [wksp, val_o.(fn)] = evalthis(conv, l-1, p + "/" + fn, wksp, fnname, val.(fn));
        end
    else 
        val_o = val;
    end
    % empty names requires no variables registered in workspace
    if ~isempty(name); wksp.(name) = val_o; end
end

function cs = matchpathpattern(conv, p)
    arguments
        conv        {mustHaveField(conv, ["default" "overwrite" "pipe"])}
        p           string
    end
    c = conv.default;
    % the latter overwrites the prior
    patts = conv.overwrite(:, 1);
    for i_k = 1 : numel(patts)
        k = patts{i_k};
        if matchpath(p, k)
            c = conv.overwrite{i_k, 2};
        end
    end
    cs = {c};
    % forming a pipeline
    patts = conv.pipe(:, 1);
    for i_k = 1 : numel(patts)
        k = patts{i_k};
        if matchpath(p, k)
            cs = [cs conv.pipe(i_k, 2)]; %#ok<AGROW> 
        end
    end
end

function m = matchpath(p, key)
    m = ~isempty(regexp(p, key, "once"));
end
