function conv = mkconvrules(f)
    % a single function handle
    conv.default = eval(f.default);
    % regexpr -> function handle
    conv.overwrite = tomap(f.overwrite);
    % regexpr -> function handle
    conv.pipe = tomap(f.pipe);    
end

function map = tomap(group)
    map = cell(numel(group), 2);
    for i_o = 1 : numel(group)
        rule = group{i_o};
        % path must be a valid regexpr
        % funs is a function handle
        map(i_o, :) = {rule.path, eval(rule.funs)};
    end
end